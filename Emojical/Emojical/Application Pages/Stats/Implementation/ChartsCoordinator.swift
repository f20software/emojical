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
    private let repository: DataRepository
    private let awardManager: AwardManager

    init(
        parent: UINavigationController,
        repository: DataRepository,
        awardManager: AwardManager)
    {
        self.parentController = parent
        self.repository = repository
        self.awardManager = awardManager
    }
    
    func monthlyStickersChart(with id: String) -> MonthlyStickerBoxController? {
        // Instantiate MonthlyStickerBoxController from the storyboard file
        guard let view = Storyboard.Stats.viewController(withIdentifier: id) as? MonthlyStickerBoxController else {
            assertionFailure("Failed to initialize MonthlyStickerBoxController")
            return nil
        }

        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = MonthlyStickerBoxPresenter(
            repository: repository,
            stampsListener: Storage.shared.stampsListener(),
            calendar: CalendarHelper.shared,
            view: view
        )
        
        return view
    }

    func goalStreaksChart(with id: String) -> GoalStreaksController? {
        // Instantiate GoalStreaksController from the storyboard file
        guard let view = Storyboard.Stats.viewController(withIdentifier: id) as? GoalStreaksController else {
            assertionFailure("Failed to initialize MonthlyStickerBoxController")
            return nil
        }

        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = GoalStreaksPresenter(
            repository: repository,
            awardManager: awardManager,
            stampsListener: Storage.shared.stampsListener(),
            calendar: CalendarHelper.shared,
            view: view
        )
        
        return view
    }

    /// Push to show specific chart form
    func showChart(_ chart: ChartType) {
        var chartView: UIViewController?
        
        switch chart {
        case .monthlyStickers:
            chartView = monthlyStickersChart(with: chart.viewControllerId)
        case .goalStreak:
            chartView = goalStreaksChart(with: chart.viewControllerId)
        default:
            break
        }
        
        guard let chartView = chartView else {
            return
        }
        
        parentController?.pushViewController(chartView, animated: true)
    }
}
