//
//  StatsPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class StatsPresenter: StatsPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let awardManager: AwardManager
    private let stampsListener: StampsListener
    private let calendar: CalendarHelper
    private weak var view: StatsView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    /// Stats mode - weekly or monthly
    private var mode: StatsMode = .month
    
    /// Copy of all stamps - used to build data model for view to show
    private var stamps = [Stamp]()
    
    /// Selected week
    private var selectedWeek = CalendarHelper.Week(Date().byAddingDays(-6))

    /// Selected month
    private var selectedMonth = CalendarHelper.Month(Date().byAddingDays(-20))

    /// Selected year
    private var selectedYear = CalendarHelper.Year(Date())

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        awardManager: AwardManager,
        stampsListener: StampsListener,
        calendar: CalendarHelper,
        view: StatsView
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
        view?.updateLayout(to: mode)

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
        view?.onNextButtonTapped = { [weak self] in
            self?.advancePeriod(by: 1)
        }
        view?.onPrevButtonTapped = { [weak self] in
            self?.advancePeriod(by: -1)
        }
        view?.onModeChanged = { [weak self] newMode in
            guard self?.mode != newMode else { return }

            self?.view?.updateLayout(to: newMode)
            self?.mode = newMode
            self?.loadViewData()
        }
    }
    
    private func loadViewData() {
        view?.updateTitle("stats_title".localized)
        switch mode {
//        case .week:
//            view?.setHeader(to: selectedWeek.label)
//            view?.showNextPrevButtons(
//                showPrev: dataBuilder.canMoveBackward(selectedWeek),
//                showNext: dataBuilder.canMoveForward(selectedWeek)
//            )
//
//            let data = dataBuilder.weeklyStats(for: selectedWeek, allStamps: stamps)
//            view?.loadWeekData(
//                header: WeekHeaderData(
//                    weekdayHeaders: selectedWeek.weekdayLettersForWeek()),
//                data: data)

        case .month:
            // view?.setHeader(to: selectedMonth.label)
            view?.showNextPrevButtons(
                showPrev: dataBuilder.canMoveBackward(selectedMonth),
                showNext: dataBuilder.canMoveForward(selectedMonth)
            )

            let data = dataBuilder.emptyStatsData(for: selectedMonth, stamps: stamps)
            view?.loadMonthData(header: selectedMonth.label, data: data)

        case .goalStreak:
            // view?.setHeader(to: selectedMonth.label)
            view?.showNextPrevButtons(
                showPrev: false,
                showNext: false
            )

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

//        case .year:
//            view?.setHeader(to: selectedYear.label)
//            view?.showNextPrevButtons(
//                showPrev: dataBuilder.canMoveBackward(selectedYear),
//                showNext: dataBuilder.canMoveForward(selectedYear)
//            )
//
//            let data = dataBuilder.emptyStatsData(for: selectedYear, stamps: stamps)
//            view?.loadYearData(data: data)
        }
    }
    
    // Move today's date one week to the past or one week to the future
    private func advancePeriod(by delta: Int) {
        switch mode {
//        case .week:
//            selectedWeek = CalendarHelper.Week(selectedWeek.firstDay.byAddingWeek(delta))
            
        case .month:
            selectedMonth = CalendarHelper.Month(selectedMonth.firstDay.byAddingMonth(delta))

        case .goalStreak:
            break

//        case .year:
//            selectedYear = CalendarHelper.Year(selectedYear.firstDay.byAddingMonth(delta*12))
        }
        
        // Update view
        loadViewData()
    }
}
