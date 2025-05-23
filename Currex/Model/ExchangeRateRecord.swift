//
//  ExchangeRateRecord.swift
//  Currex
//
//  Created by Tim Tseng on 2025/5/20.
//

import Foundation
import SwiftData

@Model
class ExchangeRateRecord: Identifiable {
    @Attribute(.unique) var id: UUID
    var baseCurrency: String
    var timestamp: Date
    @Relationship var items: [ExchangeRateItem]

    init(baseCurrency: String, timestamp: Date = .now, items: [ExchangeRateItem] = []) {
        self.id = UUID()
        self.baseCurrency = baseCurrency
        self.timestamp = timestamp
        self.items = items
    }
}
