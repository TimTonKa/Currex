//
//  UserDefaultsManager.swift
//  Currex
//
//  Created by Tim Tseng on 2025/4/29.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private init() {}

    private enum Keys {
        static let sourceCurrencyCode = "SourceCurrencyCode"
        static let targetCurrencyCode = "TargetCurrencyCode"
    }

    
    // MARK: - Source Currency
    func getSourceCurrencyCode() -> String? {
        defaults.string(forKey: Keys.sourceCurrencyCode)
    }

    func setSourceCurrencyCode(_ code: String) {
        defaults.set(code, forKey: Keys.sourceCurrencyCode)
    }

    // MARK: - Target Currency
    func getTargetCurrencyCode() -> String? {
        defaults.string(forKey: Keys.targetCurrencyCode)
    }

    func setTargetCurrencyCode(_ code: String) {
        defaults.set(code, forKey: Keys.targetCurrencyCode)
    }    
}
