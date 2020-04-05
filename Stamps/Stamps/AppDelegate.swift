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
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Setup persistent database
        let db = DataSource.shared
        try! db.setupDatabase(application)
        // WARNING! - Will override database from a json backup file 
        // db.importDatabase(from: db.localBackupFileName)
        
        AwardManager.shared.recalculateOnAppResume()

        // Initiate notification engine
        NotificationManager.shared.requestAuthorization()
        
        UNUserNotificationCenter.current().delegate = self
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

