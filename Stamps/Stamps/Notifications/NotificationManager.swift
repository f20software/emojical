//
//  NotificationManager.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/28/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NotificationManager {

    let settings: LocalSettings
    
    let reminderHour: Int = 21
    let reminderMinute: Int = 5
    
    // If application is running withing 120 minutes from reminder time, we will not show reminder
    // today but will schedule it for tomorrow
    let reminderGap: Int = 120

    // Singleton instance
    static let shared = NotificationManager(settings: LocalSettings.shared)
    
    private init(settings: LocalSettings) {
        self.settings = settings

        // Add a handler to react to updating today's stickers, so we can recalculate notifications
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotifications), name: .todayStickersUpdated, object: nil)
    }
    
    private var todayReminderTime: Date {
        return Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date())!
    }
    
    private var defaultReminderContent: UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Aren't you forgetting something?"
        content.body = "Do you want to put some stickers for today?"
        content.sound = .default
        
        return content
    }
    
    private func todayReminderContent(todayStamps: [String]) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Review today entry?"
        content.sound = .default
        if todayStamps.count == 0 {
            return defaultReminderContent
        }
        else if todayStamps.count == 1 {
            content.body = "You've recorded '\(todayStamps[0])' today. Do you want to add anything else?"
        }
        else {
            let stampsText = todayStamps.map({ "'\($0)'" }).sentence
            content.body = "You've recorded \(stampsText) today. Do you want to add anything else?"
        }
        
        return content
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            
            if error != nil {
                // Handle the error here.
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
        let notificationId = settings.todayNotificationId
        if notificationId != nil {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId!])
        }
        
        settings.todayNotificationId = createNextNotification()
    }
    
    private func createNextNotification() -> String {
        var nextNotificationDate = todayReminderTime
        var content = defaultReminderContent

        // If we're doing it within 30 minutes from the todays notification time (or if we passed that time already)
        // next reminder will be set for tomorrow
        let untilTodayReminder = Int(nextNotificationDate.timeIntervalSince(Date()) / 60)
        if untilTodayReminder < reminderGap {
            nextNotificationDate = nextNotificationDate.byAddingDays(1)
        }
        else {
            content = todayReminderContent(todayStamps: DataSource.shared.stampsNamesForDay(Date()))
        }
        
        let comps = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: nextNotificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        print("Reminder (\"\(content.body)\") is set to \(nextNotificationDate.databaseKeyWithTime)")
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        // TODO: This is actually async call and requires error handling in completion handler
        UNUserNotificationCenter.current().add(request)
        return request.identifier
    }
}
