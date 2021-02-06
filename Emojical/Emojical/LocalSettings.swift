//
//  LocalSettings.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/8/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class LocalSettings {
    
    private let todayNotificationIdKey = "todayNotificationId"
    private let reminderEnabledKey = "reminderEnabled"

    // Singleton instance
    static let shared = LocalSettings()

    private init() {
    }

    // MARK: - Public properties
    
    /// Today notification Id - to ensure we only schedule one reminder notification
    var todayNotificationId: String? {
        get {
            return stringDefault(todayNotificationIdKey)
        }
        set {
            setStringDefault(newValue, key: todayNotificationIdKey)
        }
    }

    /// Is today entry reminder enabled?
    var reminderEnabled: Bool {
        get {
            return boolDefault(reminderEnabledKey) ?? false
        }
        set {
            setBoolDefault(newValue, key: reminderEnabledKey)
        }
    }

    // MARK: - Helper methods to wrap up NSUserDefaults
    
    private func stringDefault(_ key: String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: key)
    }
    
    private func setStringDefault(_ value: String?, key: String) {
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

    private func boolDefault(_ key: String) -> Bool? {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key)
    }
    
    private func setBoolDefault(_ value: Bool, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
}
