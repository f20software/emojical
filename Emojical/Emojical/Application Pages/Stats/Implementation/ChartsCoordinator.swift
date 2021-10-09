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
            chartView = stickersMonthlyChart(with: chart.viewControllerId)
        case .goals:
            chartView = goalStatsChart(with: chart.viewControllerId)
        }
        
        guard let chartView = chartView else {
            return
        }
        
        parentController?.pushViewController(chartView, animated: true)
    }
    
    // MARK: - Private Helpers
    
    private func stickersMonthlyChart(with id: String) -> StickerMonthlyChartController? {
        // Instantiate StickerMonthlyChartController from the storyboard file
        guard let view = Storyboard.Stats.viewController(withIdentifier: id) as? StickerMonthlyChartController else {
            assertionFailure("Failed to initialize StickerMonthlyChartController")
            return nil
        }

        // Hook up a presenter and tie it together to a view controller
        view.presenter = StickerMonthlyChartPresenter(
            repository: repository,
            calendar: CalendarHelper.shared,
            view: view
        )
        
        return view
    }

    private func goalStatsChart(with id: String) -> GoalStatsChartController? {
        // Instantiate GoalStatsChartController from the storyboard file
        guard let view = Storyboard.Stats.viewController(withIdentifier: id) as? GoalStatsChartController else {
            assertionFailure("Failed to initialize GoalStatsChartController")
            return nil
        }

        // Hook up a presenter and tie it together to a view controller
        view.presenter = GoalStatsChartPresenter(
            repository: repository,
            awardManager: awardManager,
            calendar: CalendarHelper.shared,
            view: view
        )
        
        return view
    }
}
