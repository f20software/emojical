//
//  LocalSettings.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/8/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class LocalSettings {
    
    private let todayNotification = "todayNotification"
    
    // Singleton instance
    static let shared = LocalSettings()

    private init() {
    }

    // MARK: - Public properties
    
    // Daily calories limit
    var todayNotificationId: String? {
        get {
            return stringDefault(todayNotification)
        }
        set {
            if newValue != nil {
                setStringDefault(newValue!, key: todayNotification)
            }
        }
    }

    // MARK: - Helper methods to wrap up NSUserDefaults
    
    private func stringDefault(_ key: String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: key)
    }
    
    private func setStringDefault(_ value: String, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }

    private func integerDefault(_ key: String) -> Int? {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: key)
    }
    
    private func setIntegerDefault(_ value: Int, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
}
