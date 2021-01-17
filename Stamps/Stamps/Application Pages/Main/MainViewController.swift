//
//  MainViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    var todayTab: TodayViewController?
    var goalsTab: UIViewController!
    var statsTab: UIViewController!
    var optionsTab: UIViewController!

    private var newAwardCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        todayTab = ((viewControllers?[0] as? UINavigationController)?.viewControllers[0] as? TodayViewController)
        goalsTab = viewControllers![1]
        statsTab = viewControllers![2]
        optionsTab = viewControllers![3]

        // Add handlers to app wide notifications
        NotificationCenter.default.addObserver(
            self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(weekReady), name: .weekClosed, object: nil)
    }
}

// MARK: - Notification handling
extension MainViewController {

    @objc func navigateToCalendar() {
        // Move to Today's tab
        selectedIndex = 0
        
        // And navigate to current day
        todayTab?.presenter?.navigateTo(Date())
    }
    
    @objc func weekReady() {
        selectedIndex = 0
        let alert = UIAlertController(title: "Week recap is ready", message: "You've reached some goals and failed others", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Review", style: .default, handler: { (_) in
            // Show week recap for the previous week
            DispatchQueue.main.async {
                self.todayTab?.presenter?.showWeekRecapFor(Date().byAddingWeek(-1))
            }
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
