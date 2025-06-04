//
//  CurrencyViewModel.swift
//  CurrenxApp
//
//  Created by Tim Tseng on 2025/4/18.
//

import Foundation
import Combine
import OSLog
import SwiftUICore
import SwiftData

class CurrencyViewModel: ObservableObject {
    private let logger = Logger(subsystem: "", category: String(describing: CurrencyViewModel.self))
    
    private let modelContext: ModelContext
    
    // MARK: - Published Properties
    @Published var sourceCountry: CountryCurrency? {
        didSet {
            if let code = sourceCountry?.countryCode {
                UserDefaultsManager.shared.setSourceCountryCode(code)
                convert()
            }
        }
    }

    @Published var targetCountry: CountryCurrency? {
        didSet {
            if let code = targetCountry?.countryCode {
                UserDefaultsManager.shared.setTargetCountryCode(code)
                convert()
            }
        }
    }
    
    @Published var exchangeRateTimestamp: Date?

    var sourceCurrencyCode: String {
        sourceCountry?.currencyCode ?? ""
    }

    var targetCurrencyCode: String {
        targetCountry?.currencyCode ?? ""
    }

    @Published var countries: [CountryCurrency] = []
    @Published var convertedAmount: Double?
    @Published var isLoading = false

    @Published var engine = CalculatorEngine()

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var exchangeRates: [String: Double] = [:]
    private let baseCurrency = "usd"
    
    var formattedResultWithCurrency: String {
        guard let currencyCode = sourceCountry?.currencyCode else {
            return ""
        }
        
        let value = Double(engine.result) ?? 0.0
        return value.formattedWithTwoDecimal(code: currencyCode)
    }
    
    var formattedConvertedAmountWithCurrency: String {
        guard let currencyCode = targetCountry?.currencyCode else {
            return "0"
        }
        let amount = convertedAmount ?? 0.0
        return amount.formattedWithTwoDecimal(code: currencyCode)
    }
    
    var formattedExchangeRate: String? {
        guard let sourceRate = exchangeRates[sourceCurrencyCode.lowercased()],
              let targetRate = exchangeRates[targetCurrencyCode.lowercased()]
        else {
            return nil
        }

        let rate = targetRate / sourceRate
        let formatted = String(format: "%.4f", rate)
        var result = "1 \(sourceCurrencyCode.uppercased()) = \(formatted) \(targetCurrencyCode.uppercased())"
        if let timestamp = exchangeRateTimestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            result += " (\(formatter.string(from: timestamp)))"
        }
        return result
    }

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        loadCountries()
        setupBindings()
        
        let sourceCode = UserDefaultsManager.shared.getSourceCountryCode() ?? "us"
        let targetCode = UserDefaultsManager.shared.getTargetCountryCode() ?? "tw"

        self.sourceCountry = countries.first(where: { $0.countryCode.lowercased() == sourceCode.lowercased() })
        self.targetCountry = countries.first(where: { $0.countryCode.lowercased() == targetCode.lowercased() })
        
        Task {
            await fetchExchangeRates()
        }
    }

    // MARK: - Bindings
    private func setupBindings() {
        engine.$result
            .dropFirst()
            .sink { [weak self] _ in
//                self?.convert()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        engine.$expression
            .sink { [weak self] _ in
                self?.objectWillChange.send() // 手動推播變更
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    func handle(action: CalculatorButtonAction) {
        switch action {
        case .equal:
            engine.input(.equal)
            convert()
        case .clear:
            engine.input(.clear)
            convertedAmount = nil
        case .backspace:
            engine.input(.backspace)
        case .swapCurrency:
            swapCurrencies()
        default:
            if engine.result.replacingOccurrences(of: ".", with: "").count < 9 {
                engine.input(action)
            }
        }
    }

    func convert() {
        guard let amount = Double(engine.result),
              let sourceRate = exchangeRates[sourceCurrencyCode.lowercased()],
              let targetRate = exchangeRates[targetCurrencyCode.lowercased()] else {
            convertedAmount = nil
            return
        }

        let result = amount / sourceRate * targetRate
        convertedAmount = result
        logger.debug("Convert \(amount) \(self.sourceCurrencyCode.uppercased()) to \(self.targetCurrencyCode.uppercased()) → \(result)")
    }
    
    func swapCurrencies() {
        let temp = sourceCountry
        sourceCountry = targetCountry
        targetCountry = temp
        convert() // 交換後立即換算
    }

    @MainActor
    func fetchExchangeRates() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let rates = try await CurrencyAPIManager.shared.fetchExchangeRates(endpoint: baseCurrency)
            self.exchangeRates = rates
            self.exchangeRateTimestamp = Date()
            saveRates(base: baseCurrency, timestamp: Date(), rates: rates)
            
            logger.debug("Rates: \(rates)")
            convert() // 自動換算
        } catch {
            logger.error("Fetch exchange rates failed: \(error)")
            // 讀取最新一筆本地資料
            loadLatestRates()
        }
    }

    // MARK: - Private Helpers
    private func saveRates(base: String, timestamp: Date = .now, rates: [String: Double]) {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: timestamp)
        
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: todayStart) else {
            logger.error("Failed to compute end of day.")
            return
        }

        // 檢查是否已有今天的資料
        let predicate = #Predicate<ExchangeRateRecord> {
            $0.timestamp >= todayStart && $0.timestamp < endOfDay
        }

        let descriptor = FetchDescriptor<ExchangeRateRecord>(predicate: predicate)
        
        do {
            let existingRecords = try modelContext.fetch(descriptor)
            
            if let existing = existingRecords.first {
                // 已有今天的資料 → 覆蓋 items 和 timestamp
                existing.items = rates.map { ExchangeRateItem(currencyCode: $0.key, rate: $0.value) }
                existing.timestamp = timestamp
                logger.debug("Updated existing exchange rate record for today.")
            } else {
                // 沒有今天的資料 → 新增一筆
                let items = rates.map { ExchangeRateItem(currencyCode: $0.key, rate: $0.value) }
                let record = ExchangeRateRecord(baseCurrency: base, timestamp: timestamp, items: items)
                modelContext.insert(record)
                logger.debug("Inserted new exchange rate record for today.")
            }
        } catch {
            logger.error("Failed to fetch or save exchange rate record: \(error)")
        }
    }
    
    func loadLatestRates() {
        let descriptor = FetchDescriptor<ExchangeRateRecord>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        if let latest = try? modelContext.fetch(descriptor).first {
            logger.debug("Fetch rates from DB success!")
            self.exchangeRateTimestamp = latest.timestamp
            self.exchangeRates = Dictionary(uniqueKeysWithValues: latest.items.map { ($0.currencyCode, $0.rate) })
        }
    }
    
    private func loadCountries() {
        guard let url = Bundle.main.url(forResource: "Country", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(CountryCurrencyMap.self, from: data) else {
            logger.error("Failed to load or decode Country.json")
            return
        }

        countries = decoded.map { $0.value }.sorted { $0.currencyCode < $1.currencyCode }
    }
}

extension Double {
    func formattedWithTwoDecimal(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
