//
//  MainViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    var todayTab: UINavigationController?
    var todayPresenter: TodayPresenter? {
        return (todayTab?.viewControllers.first as? TodayViewController)?.presenter as? TodayPresenter
    }
    
    var goalsTab: UINavigationController?
    var statsTab: UINavigationController?
    var optionsTab: UINavigationController?

    private var newAwardCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        todayTab = viewControllers?[0] as? UINavigationController
        goalsTab = viewControllers?[1] as? UINavigationController
        statsTab = viewControllers?[2] as? UINavigationController
        optionsTab = viewControllers?[3] as? UINavigationController

        todayTab?.tabBarItem.title = "today_title".localized
        goalsTab?.tabBarItem.title = "goals_title".localized
        statsTab?.tabBarItem.title = "stats_title".localized
        optionsTab?.tabBarItem.title = "options_title".localized

        // Add handlers to app wide notifications
        NotificationCenter.default.addObserver(
            self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(weekReady), name: .weekClosed, object: nil)
        
        updateColors()
    }
}

// MARK: - Notification handling
extension MainViewController {

    @objc func navigateToCalendar() {
        // Move to Today's tab
        selectedIndex = 0
        
        // And navigate to current day
        todayPresenter?.navigateTo(Date())
    }
    
    private func updateColors() {
        UIView.appearance().tintColor = Theme.main.colors.tint
        tabBar.tintColor = Theme.main.colors.tint
    }

    @objc func weekReady() {
        
        // Move to Today page
        selectedIndex = 0
        
        let alert = UIAlertController(
            title: "week_recap_title".localized,
            message: "week_recap_message".localized,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "review_button".localized,
            style: .default,
            handler: { (_) in
            // Show week recap for the previous week
            DispatchQueue.main.async {
                self.todayPresenter?.showWeekRecapFor(Date().byAddingWeek(-1))
            }
        }))
        
        alert.addAction(UIAlertAction(
            title: "dismiss_button".localized,
            style: .cancel,
            handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
