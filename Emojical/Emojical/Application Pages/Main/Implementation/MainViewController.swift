//
//  MainViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// BarItem configuration - titles and icons
private let config: [Page: BarItemConfiguration] = [
    .today: BarItemConfiguration(
        title: "today_title".localized,
        imageName: "calendar",
        selectedImageName: "calendar"
    ),
    .goals: BarItemConfiguration(
        title: "goals_title".localized,
        imageName: "crown",
        selectedImageName: "crown.fill"
    ),
    .stickers: BarItemConfiguration(
        title: "stickers_title".localized,
        imageName: "circle.hexagongrid",
        selectedImageName: "circle.hexagongrid.fill"
    ),
    .stats: BarItemConfiguration(
        title: "charts_title".localized,
        imageName: "chart.bar",
        selectedImageName: "chart.bar.fill"
    ),
    .options: BarItemConfiguration(
        title: "options_title".localized,
        imageName: "gearshape",
        selectedImageName: "gearshape.fill"
    ),
]


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
    private let calendar = CalendarHelper.shared!

    override func viewDidLoad() {
        super.viewDidLoad()

        todayTab = viewControllers?[Page.today.rawValue] as? UINavigationController
        goalsTab = viewControllers?[Page.goals.rawValue] as? UINavigationController
        stickersTab = viewControllers?[Page.stickers.rawValue] as? UINavigationController
        statsTab = viewControllers?[Page.stats.rawValue] as? UINavigationController
        optionsTab = viewControllers?[Page.options.rawValue] as? UINavigationController

        configureBarItems()

        // Add handlers to app wide notifications
        NotificationCenter.default.addObserver(
            self, selector: #selector(navigateToCalendar), name: .navigateToToday, object: nil)
        
        delegate = self
        updateColors()
        navigateToCalendar()
    }
    
    private func configureBarItems() {
        let iconConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        config.forEach { page, config in
            guard let vc = viewControllers?[page.rawValue] else { return }
            vc.tabBarItem.title = config.title
            vc.tabBarItem.image = UIImage(
                systemName: config.imageName,
                withConfiguration: iconConfiguration
            )!
            vc.tabBarItem.selectedImage = UIImage(
                systemName: config.selectedImageName,
                withConfiguration: iconConfiguration
            )!
        }
    }
}

// MARK: - UITabBarControllerDelegate handling
extension MainViewController : UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // If we're navigating to TodayViewController - select today's date
        if ((viewController as? UINavigationController)?
            .visibleViewController as? TodayViewController) != nil {
            todayPresenter?.navigateTo(calendar.today)
        }
    }
}

// MARK: - Notification handling
extension MainViewController {

    @objc func navigateToCalendar() {
        // Move to Today's tab
        navigateTo(.today)

        // And navigate to current day
        todayPresenter?.navigateTo(calendar.today)
    }
    
    private func updateColors() {
        UIView.appearance().tintColor = Theme.main.colors.tint
        tabBar.tintColor = Theme.main.colors.tint
    }
}

extension MainViewController: MainCoordinatorProtocol {
 
    func navigateTo(_ page: Page) {
        selectedIndex = page.rawValue
    }
}
