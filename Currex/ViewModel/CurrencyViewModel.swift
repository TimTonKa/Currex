//
//  CurrencyViewModel.swift
//  CurrenxApp
//
//  Created by Tim Zheng on 2025/4/18.
//

import Foundation
import Combine
import OSLog

class CurrencyViewModel: ObservableObject {
    private let logger = Logger(subsystem: "", category: String(describing: CurrencyViewModel.self))
    
    // MARK: - Published Properties
    @Published var sourceCountry: CountryCurrency? {
        didSet {
            if let code = sourceCountry?.countryCode {
                UserDefaultsManager.shared.setSourceCurrencyCode(code)
                convert()
            }
        }
    }

    @Published var targetCountry: CountryCurrency? {
        didSet {
            if let code = targetCountry?.countryCode {
                UserDefaultsManager.shared.setTargetCurrencyCode(code)
                convert()
            }
        }
    }

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
    
    var formattedResultWithCurrency: String {
        guard let value = Double(engine.result), let currencyCode = sourceCountry?.currencyCode else { return "" }
        return value.formattedWithCurrency(code: currencyCode)
    }
    
    var formattedConvertedAmountWithCurrency: String {
        guard let amount = convertedAmount, let currencyCode = targetCountry?.currencyCode else { return "0" }
        return amount.formattedWithCurrency(code: currencyCode)
    }

    // MARK: - Init
    init() {
        loadCountries()
        setupBindings()
        
        let sourceCode = UserDefaultsManager.shared.getSourceCurrencyCode() ?? "us"
        let targetCode = UserDefaultsManager.shared.getTargetCurrencyCode() ?? "tw"

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
            let rates = try await CurrencyAPIManager.shared.fetchExchangeRates(endpoint: "usd")
            self.exchangeRates = rates
            convert() // 自動換算
        } catch {
            logger.error("Fetch exchange rates failed: \(error)")
        }
    }

    // MARK: - Private Helpers
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
    func formattedWithCurrency(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code.uppercased()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
