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
    var awardsTab: UIViewController!
    var stickersTab: UIViewController!
    var goalsTab: UIViewController!
    var optionsTab: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Save off default tabs so we can dynamically show/hide them
        // based on user permissions
        calendarTab = viewControllers![0]
        awardsTab = viewControllers![1]
        stickersTab = viewControllers![2]
        goalsTab = viewControllers![3]
        optionsTab = viewControllers![4]

        // Subscribe to app notifications on when user sign in/out
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)
    }
    
    @objc func navigateToCalendar() {
        selectedIndex = 0
    }
}
