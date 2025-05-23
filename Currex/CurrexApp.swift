//
//  CurrexApp.swift
//  Currex
//
//  Created by Tim Tseng on 2025/5/1.
//

import SwiftUI
import SwiftData

@main
struct CurrexApp: App {
    var body: some Scene {
        WindowGroup {
            AppEntry()
        }
        .modelContainer(for: [ExchangeRateRecord.self, ExchangeRateItem.self])
    }
}
