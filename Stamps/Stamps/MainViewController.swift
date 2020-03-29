//
//  MainViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    var calendarTab: UIViewController!
    var stickersTab: UIViewController!
    var goalsTab: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Save off default tabs so we can dynamically show/hide them
        // based on user permissions
        calendarTab = viewControllers![0]
        stickersTab = viewControllers![1]
        goalsTab = viewControllers![2]

        // Subscribe to app notifications on when user sign in/out
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)
    }
    
    @objc func navigateToCalendar() {
        selectedIndex = 0
    }
}
