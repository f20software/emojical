//
//  GoalStreaksPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 9/19/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class GoalStreaksPresenter: ChartPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let awardManager: AwardManager
    private let stampsListener: StampsListener
    private let calendar: CalendarHelper
    private weak var view: GoalStreaksView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    /// Copy of all stamps - used to build data model for view to show
    private var stamps = [Stamp]()
    
    /// Selected month
    private var selectedMonth = CalendarHelper.Month(Date().byAddingDays(-20))

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        awardManager: AwardManager,
        stampsListener: StampsListener,
        calendar: CalendarHelper,
        view: GoalStreaksView
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
            
            self.stamps = self.repository.allStamps().sorted(by: { $0.count > $1.count })
            self.loadViewData()
        })
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
    }
    
    private func loadViewData() {
        let data: [GoalStreakData2] = repository.allGoals().compactMap({
            guard let goalId = $0.id else { return nil }

            let stamp = self.repository.stampBy(id: $0.stamps.first)
            let history = self.dataBuilder.historyFor(goal: goalId, limit: 12)
            
            return GoalStreakData2(
                goalId: goalId,
                period: $0.period,
                count: $0.count,
                streak: history?.reached.streak ?? 0,
                icon: GoalOrAwardIconData(
                    stamp: stamp,
                    goal: $0,
                    progress: self.awardManager.currentProgressFor($0)
                )
            )
        }).sorted(by: { $0.streak > $1.streak })
        view?.loadGoalStreaksData(data: data)
    }
    
    // Move today's date one week to the past or one week to the future
    private func advancePeriod(by delta: Int) {
        selectedMonth = CalendarHelper.Month(selectedMonth.firstDay.byAddingMonth(delta))
        // Update view
        loadViewData()
    }
}
