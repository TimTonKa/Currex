//
//  CountryCurrency.swift
//  CurrenxApp
//
//  Created by Tim Zheng on 2025/4/18.
//

import Foundation

struct CountryCurrency: Decodable, Identifiable {
    var id: String { countryIsoNumeric }
    let countryIsoNumeric: String
    let countryName: String
    let currencyCode: String
    
    private enum CodingKeys: String, CodingKey {
        case countryIsoNumeric = "country_iso_numeric"
        case countryName = "country_name"
        case currencyCode = "currency_code"
    }
}

typealias CountryCurrencyMap = [String: CountryCurrency]
