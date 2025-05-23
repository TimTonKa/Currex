//
//  ExchangeRateItem.swift
//  Currex
//
//  Created by Tim Tseng on 2025/5/20.
//
import SwiftData

@Model
class ExchangeRateItem {
    var currencyCode: String
    var rate: Double

    init(currencyCode: String, rate: Double) {
        self.currencyCode = currencyCode
        self.rate = rate
    }
}
