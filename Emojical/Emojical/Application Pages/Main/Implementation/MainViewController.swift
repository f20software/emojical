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
    var stickersTab: UINavigationController?
    var statsTab: UINavigationController?
    var optionsTab: UINavigationController?

    private var newAwardCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        goalsTab = viewControllers?[0] as? UINavigationController
        stickersTab = viewControllers?[1] as? UINavigationController
        todayTab = viewControllers?[2] as? UINavigationController
        statsTab = viewControllers?[3] as? UINavigationController
        optionsTab = viewControllers?[4] as? UINavigationController

        todayTab?.tabBarItem.title = "today_title".localized
        goalsTab?.tabBarItem.title = "goals_tab_title".localized
        stickersTab?.tabBarItem.title = "stickers_tab_title".localized
        statsTab?.tabBarItem.title = "charts_title".localized
        optionsTab?.tabBarItem.title = "options_title".localized

        // Add handlers to app wide notifications
        NotificationCenter.default.addObserver(
            self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)
        
        delegate = self
        updateColors()
        navigateToCalendar()
    }
}

// MARK: - Notification handling
extension MainViewController : UITabBarControllerDelegate {

    @objc func navigateToCalendar() {
        // Move to Today's tab
        navigateTo(.today)

        // And navigate to current day
        todayPresenter?.navigateTo(Date())
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // If we're navigating to TodayViewController - select today's date
        if ((viewController as? UINavigationController)?
            .visibleViewController as? TodayViewController) != nil {
            todayPresenter?.navigateTo(Date())
        }
    }
    
    private func updateColors() {
        UIView.appearance().tintColor = Theme.main.colors.tint
        tabBar.tintColor = Theme.main.colors.tint
    }
}

extension MainViewController: MainCoordinatorProtocol {
 
    func navigateTo(_ page: Page) {
        switch page {
        case .goals:
            selectedIndex = 0
            
        case .stickers:
            selectedIndex = 1

        case .today:
            selectedIndex = 2

        case .stats:
            selectedIndex = 3
            
        case .options:
            selectedIndex = 4
        }
    }
}
