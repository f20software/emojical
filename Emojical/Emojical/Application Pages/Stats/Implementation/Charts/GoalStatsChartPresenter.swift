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
    private let stampsListener: StampsListener
    private let calendar: CalendarHelper
    private weak var view: GoalStatsChartView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    /// Copy of all stamps - used to build data model for view to show
    private var stamps = [Stamp]()

    /// Sort order
    private var sort: GoalStatsSortOrder = .streakLength

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        awardManager: AwardManager,
        stampsListener: StampsListener,
        calendar: CalendarHelper,
        view: GoalStatsChartView
    ) {
        self.repository = repository
        self.awardManager = awardManager
        self.stampsListener = stampsListener
        self.calendar = calendar
        self.view = view
        
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: calendar
        )
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()

        // Load initial set of data
        stamps = repository.allStamps()
        
        // Subscribe to stamp listner in case stamps array ever changes
        stampsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            guard let self = self else { return }
            
            self.stamps = self.repository.allStamps()
            self.loadViewData()
        })
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onCountersToggleTapped = {
            if self.sort == .totalCount {
                self.sort = .streakLength
            } else {
                self.sort = .totalCount
            }
            self.loadViewData()
        }
    }
    
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
        })// .sorted(by: { $0.streak > $1.streak })
        view?.loadGoalsData(data: data, sortOrder: sort)
    }
}
