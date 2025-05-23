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
        static let sourceCountryCode = "SourceCountryCode"
        static let targetCountryCode = "TargetCountryCode"
    }

    
    // MARK: - Source Country
    func getSourceCountryCode() -> String? {
        defaults.string(forKey: Keys.sourceCountryCode)
    }

    func setSourceCountryCode(_ code: String) {
        defaults.set(code, forKey: Keys.sourceCountryCode)
    }

    // MARK: - Target Country
    func getTargetCountryCode() -> String? {
        defaults.string(forKey: Keys.targetCountryCode)
    }

    func setTargetCountryCode(_ code: String) {
        defaults.set(code, forKey: Keys.targetCountryCode)
    }
}
