//
//  CurrencyAPIManager.swift
//  CurrenxApp
//
//  Created by Tim Tseng on 2025/4/18.
//

import Foundation
import OSLog

final class CurrencyAPIManager {
    static let shared = CurrencyAPIManager()
    private let logger = Logger(subsystem: "", category: String(describing: CurrencyAPIManager.self))

    private init() {}

    func fetchExchangeRates(endpoint: String) async throws -> [String: Double] {
        let urlString = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/\(endpoint.lowercased()).json"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        logger.debug("Request url: \(urlString)")
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        return decoded.rates
    }
}
