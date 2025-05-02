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
    @Published var sourceCurrencyCode: String {
        didSet {
            UserDefaultsManager.shared.setSourceCurrencyCode(sourceCurrencyCode)
            convert()
        }
    }
    
    @Published var targetCurrencyCode: String {
        didSet {
            UserDefaultsManager.shared.setTargetCurrencyCode(targetCurrencyCode)
            convert()
        }
    }

    @Published var countries: [CountryCurrency] = []
    @Published var convertedAmount: Double?
    @Published var isLoading = false

    @Published var engine = CalculatorEngine()

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var exchangeRates: [String: Double] = [:]

    // MARK: - Init
    init() {
        self.sourceCurrencyCode = UserDefaultsManager.shared.getSourceCurrencyCode() ?? "usd"
        self.targetCurrencyCode = UserDefaultsManager.shared.getTargetCurrencyCode() ?? "twd"

        loadCountries()
        setupBindings()
        
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
        default:
            engine.input(action)
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
