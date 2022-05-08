//
//  GoalStatsChartPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 9/19/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class GoalStatsChartPresenter: ChartPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let awardManager: AwardManager
    private let calendar: CalendarHelper
    private weak var view: GoalStatsChartView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    /// Sort order
    private var sort: GoalStatsSortOrder = .totalCount

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        awardManager: AwardManager,
        calendar: CalendarHelper,
        view: GoalStatsChartView,
        chartType: ChartType
    ) {
        self.repository = repository
        self.awardManager = awardManager
        self.calendar = calendar
        self.view = view
        
        switch chartType {
        case .goalsTotals:
            sort = .totalCount
        case .goalsStreaks:
            sort = .streakLength
        default:
            assertionFailure("Not implemented")
        }
        
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: calendar
        )
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func loadViewData() {
        let data: [GoalStats] = repository.allGoals().compactMap({
            guard let goalId = $0.id else { return nil }

            let stamp = self.repository.stampBy(id: $0.stamps.first)
            let history = self.dataBuilder.historyFor(goal: goalId, limit: 12)
            
            return GoalStats(
                goalId: goalId,
                period: $0.period,
                count: $0.count,
                streak: history?.reached.streak ?? 0,
                icon: GoalOrAwardIconData(
                    stamp: stamp,
                    goal: $0,
                    progress: self.awardManager.currentProgressFor($0)
                ),
                chart: history?.chart
            )
        })
        view?.loadGoalsData(data: data, sortOrder: sort)
    }
}
