//
//  NotificationManager.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/28/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NotificationManager: NotificationManagerProtocol {

    // MARK: - DI
    
    let settings: LocalSettings
    let calendar: CalendarHelper
    
    private let newStyleNotifications = true
    
    // MARK: - Singleton
    static let shared = NotificationManager(
        settings: LocalSettings.shared,
        calendar: CalendarHelper.shared
    )

    // MARK: - State
    
    /// NotificationCenter instance
    private var userNotificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    /// Reminder for day when no stickers are recorded
    private var emptyDayReminderContent: UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "new_reminder_title".localized
        content.body = "new_reminder_body".localized
        content.sound = .default
        
        return content
    }

    private init(
        settings: LocalSettings,
        calendar: CalendarHelper
    ) {
        self.settings = settings
        self.calendar = calendar

        // Subscribe to significant time change notification
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotifications),
            name: UIApplication.significantTimeChangeNotification, object: nil)
    }
    
    /// Request notification authorization
    func requestAuthorization() {
        userNotificationCenter.requestAuthorization(
            options: [.alert, .sound, .badge, .provisional]) { granted, error in
            
            if error != nil {
                NSLog("Failed to request notification authorization [\(error!.localizedDescription)]")
            }
            
            self.refreshNotifications()
        }
    }

    /// Refresh reminder notifications - deletes existing ones and re-create based on the settings
    @objc func refreshNotifications() {
        
        // Remove everything that is scheduled
        userNotificationCenter.removeAllPendingNotificationRequests()
        
        // Don't schedule anything if user opted out
        if !settings.reminderEnabled {
            return
        }

        createNextNotifications().forEach {
            userNotificationCenter.add($0) { (error) in
                if error != nil {
                    NSLog("Failed to add notification [\(error!.localizedDescription)]")
                }
            }
        }
    }
        
    // MARK: - Private helpers
    
    // Create list of notification requests for the next few days
    private func createNextNotifications() -> [UNNotificationRequest] {
        var result: [UNNotificationRequest] = []
        let reminderTime = settings.reminderTime
        var nextNotificationDate = calendar.todayAtTime(
            hour: reminderTime.hour,
            minute: reminderTime.minute
        )
        let content = emptyDayReminderContent
        
        // If notifiction time is in the past - bump it one day
        while nextNotificationDate.timeIntervalSinceNow < 0 {
            nextNotificationDate = nextNotificationDate.byAddingDays(1)
        }

        NSLog("Creating reminder [\"\(content.body)\"] for the next week")

        for _ in 0...2 {

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
}
