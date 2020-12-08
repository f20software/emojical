//
//  AppDelegate.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let navigateToToday = NSNotification.Name("NavigateToToday")
    static let todayStickersUpdated = NSNotification.Name("TodayStickersUpdated")
    static let awardsAdded = NSNotification.Name("AwardsAdded")
    static let awardsDeleted = NSNotification.Name("AwardsDeleted")
    static let newAwardsSeen = NSNotification.Name("NewAwardsSeen")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        /// Setup data storage. Change this line to swap to another data storage mechanism.
        Storage.shared = GRDBDataProvider(app: application)
        /// Setup calendar helper using first and last recorded diary entries
        CalendarHelper.shared = CalendarHelper(
            from: Storage.shared.repository.getFirstDiaryDate() ?? Date(year: 2020, month: 1, day: 20),
            to: Storage.shared.repository.getLastDiaryDate() ?? Date(year: 2022, month: 11, day: 20))
        
        AwardManager.shared.recalculateOnAppResume()

        // Initiate notification engine
        NotificationManager.shared.requestAuthorization()
        
        UNUserNotificationCenter.current().delegate = self
        
        UIView.appearance().tintColor = UIColor.appTintColor
        return true
    }

    // MARK: Notification handling
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        // Post application notification to navigate to today's date
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            NotificationCenter.default.post(name: .navigateToToday, object: nil)
        })
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    }
    
    // MARK: UISceneSession Lifecycle

    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

