//
//  CountryCurrency.swift
//  CurrenxApp
//
//  Created by Tim Zheng on 2025/4/18.
//

import Foundation

struct CountryCurrency: Decodable, Identifiable {
    var id: String { countryIsoNumeric }
    let countryCode: String
    let countryIsoNumeric: String
    let countryName: String
    let currencyCode: String
    
    private enum CodingKeys: String, CodingKey {
        case countryIsoNumeric = "country_iso_numeric"
        case countryName = "country_name"
        case currencyCode = "currency_code"
        case countryCode = "country_code"
    }
}

typealias CountryCurrencyMap = [String: CountryCurrency]

extension CountryCurrency {
    var flag: String {
        countryCode.flagEmoji
    }
}

extension String {
    var flagEmoji: String {
        let base: UInt32 = 127397
        return self.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value)
        }.map { String($0) }.joined()
    }
}
