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

    private var newAwardCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarTab = viewControllers![0]
        awardsTab = viewControllers![1]
        stickersTab = viewControllers![2]
        goalsTab = viewControllers![3]
        optionsTab = viewControllers![4]

        // Subscribe to app notifications on when user sign in/out
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(awardsAdded), name: .awardsAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(awardsDeleted), name: .awardsDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newAwardsSeen), name: .newAwardsSeen, object: nil)
    }
}

// MARK: - Notification handling
extension MainViewController {

    @objc func navigateToCalendar() {
        selectedIndex = 0
    }

    @objc func awardsAdded(notification: Notification) {
        guard let awards = notification.object as? [Award] else { return }
        newAwardCounter += awards.count
        tabBar.items?[1].badgeValue = "\(newAwardCounter)"
    }

    @objc func awardsDeleted(notification: Notification) {
        guard let awards = notification.object as? [Award] else { return }

        newAwardCounter -= awards.count
        if newAwardCounter < 0 {
            newAwardCounter = 0
        }
        tabBar.items?[1].badgeValue = newAwardCounter > 0 ? "\(newAwardCounter)" : nil
    }

    @objc func newAwardsSeen(notification: Notification) {
        newAwardCounter = 0
        tabBar.items?[1].badgeValue = nil
    }
}
