//
//  ExchangeRateResponse.swift
//  CurrenxApp
//
//  Created by Tim Zheng on 2025/4/19.
//

import Foundation

struct ExchangeRateResponse: Decodable {
    let date: String
    let baseCurrency: String
    let rates: [String: Double]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)

        // decode known key
        self.date = try container.decode(String.self, forKey: DynamicKey(stringValue: "date")!)

        // find unknown (dynamic) key
        let dynamicKeys = container.allKeys.filter { $0.stringValue != "date" }
        guard let baseKey = dynamicKeys.first else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No base currency key found"))
        }

        self.baseCurrency = baseKey.stringValue
        self.rates = try container.decode([String: Double].self, forKey: baseKey)
    }
}

struct DynamicKey: CodingKey {
    //Only support string key
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }

    //CodingKey must implement string value and int value
    var intValue: Int? = nil
    init?(intValue: Int) { return nil }
}
