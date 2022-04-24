//
//  NotificationManager.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/28/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NotificationManager {

    // MARK: - DI
    
    let settings: LocalSettings
    let calendar: CalendarHelper
    
    private let newStyleNotifications = true
    
    // MARK: - Singleton
    static let shared = NotificationManager(
        settings: LocalSettings.shared,
        calendar: CalendarHelper.shared
    )

    /// If application is running withing 120 minutes from reminder time,
    /// we will not show reminder today but will schedule it for tomorrow
    private let reminderGap: Int = 120
    
    var userNotificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    private init(
        settings: LocalSettings,
        calendar: CalendarHelper
    ) {
        self.settings = settings
        self.calendar = calendar

        // Add a handler to react to updating today's stickers, so we can recalculate notifications
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotifications), name: .todayStickersUpdated, object: nil)

        // Subscribe to significant time change notification
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotifications),
            name: UIApplication.significantTimeChangeNotification, object: nil)

    }
    
    /// Reminder for day when no stickers are recorded
    private var emptyDayReminderContent: UNNotificationContent {
        let content = UNMutableNotificationContent()
        if newStyleNotifications {
            content.title = "new_reminder_title".localized
            content.body = "new_reminder_body".localized
        } else {
            content.title = "empty_day_title".localized
            content.body = "empty_day_body".localized
        }
        content.sound = .default
        
        return content
    }
    
    private func todayReminderContent(todayStamps: [String]) -> UNNotificationContent {
        guard todayStamps.count > 0 else {
            return emptyDayReminderContent
        }

        let content = UNMutableNotificationContent()
        content.title = "filled_day_title".localized

        var stickers = todayStamps[0]
        if todayStamps.count > 1 {
            stickers = todayStamps.map({ "'\($0)'" }).sentence
        }
        content.body = "filled_day_body".localized(stickers)
        content.sound = .default

        return content
    }
    
    func requestAuthorization() {
        userNotificationCenter.requestAuthorization(
            options: [.alert, .sound, .badge, .provisional]) { granted, error in
            
            if error != nil {
                NSLog("Failed to request notification authorization [\(error!.localizedDescription)]")
            }
            
            self.refreshNotifications()
        }
    }
    
//    func checkNotificationStatus() {
//        let center = UNUserNotificationCenter.current()
//        center.getNotificationSettings { settings in
//            
//            guard (settings.authorizationStatus == .authorized) ||
//                  (settings.authorizationStatus == .provisional) else { return }
//
//            if settings.alertSetting == .enabled {
//                // Schedule an alert-only notification.
//            }
//        }
//    }
    
    @objc func refreshNotifications() {
        if let existingId = settings.todayNotificationId {
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [existingId])
            settings.todayNotificationId = nil
        }
        let existingIds = settings.reminderIds
        if existingIds.isEmpty == false {
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: existingIds)
            settings.reminderIds = []
        }
        
        // Don't schedule anything if user opted out
        if !settings.reminderEnabled {
            return
        }

        if newStyleNotifications {
            let notifications = createNextNotifications()
            settings.reminderIds = notifications.map { $0.identifier }
            notifications.forEach {
                userNotificationCenter.add($0) { (error) in
                    if error != nil {
                        NSLog("Failed to add notification [\(error!.localizedDescription)]")
                    }
                }
            }
        } else {
            let notification = createNextNotification()
            settings.todayNotificationId = notification.identifier
            userNotificationCenter.add(notification) { (error) in
                if error != nil {
                    NSLog("Failed to add notification [\(error!.localizedDescription)]")
                }
            }
        }
    }
    
    private func createNextNotifications() -> [UNNotificationRequest] {
        var result: [UNNotificationRequest] = []
        let reminderTime = settings.reminderTime
        var nextNotificationDate = calendar.todayAtTime(
            hour: reminderTime.hour,
            minute: reminderTime.minute
        )
        let content = emptyDayReminderContent
        
        if nextNotificationDate.timeIntervalSinceNow < 0 {
            nextNotificationDate = nextNotificationDate.byAddingDays(1)
        }

        NSLog("Creating reminder [\"\(content.body)\"] for the next week")

        for _ in 0...7 {

            let comps = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: nextNotificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            NSLog("\(nextNotificationDate.databaseKeyWithTime)")
            
            // Create the request
            result.append(UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            ))
            
            nextNotificationDate = nextNotificationDate.byAddingDays(1)
        }
        
        return result
    }

    private func createNextNotification() -> UNNotificationRequest {
        let reminderTime = settings.reminderTime
        var nextNotificationDate = calendar.todayAtTime(
            hour: reminderTime.hour,
            minute: reminderTime.minute
        )
        var content = emptyDayReminderContent

        // If we're doing it within 30 minutes from the todays notification time (or if we passed that time already)
        // next reminder will be set for tomorrow
        let untilTodayReminder = Int(nextNotificationDate.timeIntervalSince(Date()) / 60)
        if untilTodayReminder < reminderGap {
            nextNotificationDate = nextNotificationDate.byAddingDays(1)
        }
        else {
            let stickers = Storage.shared.repository.stampsFor(day: Date())
            content = todayReminderContent(todayStamps: stickers.map({
                return $0.name.isEmpty ? $0.label : $0.name
            }))
        }
        
        let comps = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: nextNotificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        NSLog("Reminder (\"\(content.body)\") is set to \(nextNotificationDate.databaseKeyWithTime)")
        
        // Create the request
        return UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
    }
}
