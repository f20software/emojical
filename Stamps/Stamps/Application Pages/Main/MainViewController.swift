//
//  MainViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    var todayTab: UIViewController!
    var goalsTab: UIViewController!
    var statsTab: UIViewController!
    var optionsTab: UIViewController!

    private var newAwardCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        todayTab = viewControllers![0]
        goalsTab = viewControllers![1]
        statsTab = viewControllers![2]
        optionsTab = viewControllers![3]

        // Subscribe to app notifications on when user sign in/out
        NotificationCenter.default.addObserver(
            self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(weekReady), name: .weekClosed, object: nil)
    }
}

// MARK: - Notification handling
extension MainViewController {

    @objc func navigateToCalendar() {
        selectedIndex = 0
    }
    
    @objc func weekReady() {
        let alert = UIAlertController(title: "Week recap is ready", message: "You've reached some goals and failed others", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Review", style: .default, handler: { (_) in
            self.selectedIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                NotificationCenter.default.post(name: .viewWeekRecap, object: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
