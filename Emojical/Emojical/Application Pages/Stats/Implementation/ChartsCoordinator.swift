//
//  ChartsCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class ChartsCoordinator: ChartsCoordinatorProtocol {
    
    // MARK: - DI

    private weak var parentController: UINavigationController?
    private let repository: DataRepository!
    private let awardManager: AwardManager!

    init(
        parent: UINavigationController,
        repository: DataRepository)
    {
        self.parentController = parent
        self.repository = repository
        self.awardManager = AwardManager.shared
    }
    
    /// Push to show specific Chart form
    func showChart(_ chart: ChartType) {
        var chartView: UIViewController?
        
        switch chart {
        case .monthlyStickers:
            chartView = stickersMonthlyBoxChart(with: chart.viewControllerId)
        case .goalStreak:
            chartView = goalStreaksChart(with: chart.viewControllerId)
        }
        
        guard let chartView = chartView else {
            return
        }
        
        parentController?.pushViewController(chartView, animated: true)
    }
    
    // MARK: - Private Helpers
    
    private func stickersMonthlyBoxChart(with id: String) -> StickerMonthlyBoxController? {
        // Instantiate StickerMonthlyBoxController from the storyboard file
        guard let view = Storyboard.Stats.viewController(withIdentifier: id) as? StickerMonthlyBoxController else {
            assertionFailure("Failed to initialize StickerMonthlyBoxController")
            return nil
        }

        // Hook up a presenter and tie it together to a view controller
        view.presenter = StickerMonthlyBoxPresenter(
            repository: repository,
            stampsListener: Storage.shared.stampsListener(),
            calendar: CalendarHelper.shared,
            view: view
        )
        
        return view
    }

    private func goalStreaksChart(with id: String) -> GoalStreaksController? {
        // Instantiate GoalStreaksController from the storyboard file
        guard let view = Storyboard.Stats.viewController(withIdentifier: id) as? GoalStreaksController else {
            assertionFailure("Failed to initialize GoalStreaksController")
            return nil
        }

        // Hook up a presenter and tie it together to a view controller
        view.presenter = GoalStreaksPresenter(
            repository: repository,
            awardManager: awardManager,
            stampsListener: Storage.shared.stampsListener(),
            calendar: CalendarHelper.shared,
            view: view
        )
        
        return view
    }
}
