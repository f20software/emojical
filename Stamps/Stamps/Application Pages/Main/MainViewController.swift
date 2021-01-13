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
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)
    }
}

// MARK: - Notification handling
extension MainViewController {

    @objc func navigateToCalendar() {
        selectedIndex = 0
    }
}
