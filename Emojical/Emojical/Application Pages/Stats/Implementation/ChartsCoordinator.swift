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
        var chartView: UINavigationController?
        
        switch chart {
        case .monthlyStickers:
            chartView = stickersMonthlyChart(with: chart.viewControllerId)
        case .goalsTotals:
            chartView = goalStatsChart(with: chart.viewControllerId, type: chart)
        case .goalsStreaks:
            chartView = goalStatsChart(with: chart.viewControllerId, type: chart)
        }
        
        guard let chartView = chartView else {
            return
        }
        
        parentController?.present(chartView, animated: true)
    }
    
    // MARK: - Private Helpers
    
    private func stickersMonthlyChart(with id: String) -> UINavigationController? {
        // Instantiate StickerMonthlyChartController from the storyboard file
        guard let nav = Storyboard.Stats.viewController(with: id) as? UINavigationController,
              let view = nav.viewControllers.first as? StickerMonthlyChartController else {
            assertionFailure("Failed to initialize StickerMonthlyChartController")
            return nil
        }

        // Hook up a presenter and tie it together to a view controller
        view.presenter = StickerMonthlyChartPresenter(
            repository: repository,
            calendar: CalendarHelper.shared,
            view: view
        )
        
        return nav
    }

    private func goalStatsChart(with id: String, type: ChartType) -> UINavigationController? {
        // Instantiate GoalStatsChartController from the storyboard file
        guard
            let nav = Storyboard.Stats.viewController(with: id) as? UINavigationController,
              let view = nav.viewControllers.first as? GoalStatsChartController else {
            assertionFailure("Failed to initialize GoalStatsChartController")
            return nil
        }

        // Hook up a presenter and tie it together to a view controller
        view.presenter = GoalStatsChartPresenter(
            repository: repository,
            awardManager: awardManager,
            calendar: CalendarHelper.shared,
            view: view,
            chartType: type
        )
        
        return nav
    }
}
