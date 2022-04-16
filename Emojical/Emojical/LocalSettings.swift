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
    private let reminderTimeHourKey = "reminderTimeHour"
    private let reminderTimeMinuteKey = "reminderTimeMinute"
    private let stickerStyleKey = "stickerStyle"
    private let onboardingSeenKey = "onboardingSeen"

    // Singleton instance
    static let shared = LocalSettings()

    private init() {
    }

    // MARK: - Public properties

    /// Whether specific onboarding message has been shown or not
    func isOnboardingSeen(_ message: String) -> Bool {
        return boolDefault("\(onboardingSeenKey)-\(message)") ?? false
    }
    
    /// Record the fact that onboarding has been shown
    func seenOnboarding(_ message: String) {
        setBoolDefault(true, key: "\(onboardingSeenKey)-\(message)")
    }

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
    
    /// Reminder time 
    var reminderTime: (hour: Int, minute: Int) {
        get {
            return (
                integerDefault(reminderTimeHourKey) ?? 21,
                integerDefault(reminderTimeMinuteKey) ?? 5
            )
        }
        set {
            setIntegerDefault(newValue.hour, key: reminderTimeHourKey)
            setIntegerDefault(newValue.minute, key: reminderTimeMinuteKey)
        }
    }

    /// Is today entry reminder enabled?
    var stickerStyle: StickerStyle {
        get {
            return StickerStyle(rawValue: integerDefault(stickerStyleKey) ?? 1) ?? .borderless
        }
        set {
            setIntegerDefault(newValue.rawValue, key: stickerStyleKey)
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
        if defaults.string(forKey: key) != nil {
            return defaults.integer(forKey: key)
        } else {
            return nil
        }
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
