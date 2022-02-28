//
//  AppDelegate.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    
    /// Navigate to today's data in Today view. This notification will get generated when user taps on the reminder
    static let navigateToToday = NSNotification.Name("NavigateToToday")
    
    /// When today stickers got updated we need to re-generate reminder notification
    static let todayStickersUpdated = NSNotification.Name("TodayStickersUpdated")
    
    /// Week is closed, awards were given
    static let weekClosed = NSNotification.Name("LastWeekClosed")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    /// Full path to the application.txt log file
    static var applicationLogFile: String? {
        do {
            let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return documentDirectoryURL.appendingPathComponent("application.txt").path
        } catch {
            return nil
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Redirect stderr to log file
        #if !targetEnvironment(simulator)
        if let file = AppDelegate.applicationLogFile {
            freopen(file, "a", stderr)
        }
        #endif
        
        let version = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) ?? "Unknown"
        NSLog("STARTING UP... VERSION \(version)")
        NSLog("didFinishLaunchingWithOptions")

        // Setup data storage. Change this line to swap to another data storage mechanism.
        Storage.shared = GRDBDataProvider(app: application)
        
        // Setup calendar helper
        CalendarHelper.shared = CalendarHelper()

        // Coach messages manager
        CoachMessageManager.shared = CoachMessageManager(
            awardListener: Storage.shared.awardsListener(),
            repository: Storage.shared.repository
        )

        AwardManager.shared.recalculateOnAppResume()

        // Initiate notification engine
        NotificationManager.shared.requestAuthorization()
        UNUserNotificationCenter.current().delegate = self
        
//      Storage.shared.repository.lastWeekUpdate = Date(yyyyMmDd: "2021-01-16")

//      Un-deleting specific stamp that I deleted accidentaly
        
        let repo = Storage.shared.repository
        repo.createAdHocEntries()
//      var sticker = repo.stampById(15)
//      sticker?.deleted = false
//      try! repo.save(stamp: sticker!)
        
        UIView.appearance().tintColor = Theme.main.colors.tint
        return true
    }
    
    func applicationSignificantTimeChange(_ application: UIApplication) {
        AwardManager.shared.recalculateOnAppResume()
        NotificationCenter.default.post(name: UIApplication.significantTimeChangeNotification, object: nil)
    }

    // MARK: Notification handling
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        // Post application notification to navigate to today's date
        NotificationCenter.default.post(name: .navigateToToday, object: nil)
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

