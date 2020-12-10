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
    private let stampsListener: StampsListener
    private let calendar: CalendarHelper
    private weak var view: StatsView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    /// Stats mode - weekly or monthly
    private var mode: StatsMode = .week
    
    /// Copy of all stamps - used to build data model for view to show
    private var stamps = [Stamp]()
    
    /// Selected week
    private var selectedWeek = CalendarHelper.Week(Date())

    /// Selected month
    private var selectedMonth = CalendarHelper.Month(Date())

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        calendar: CalendarHelper,
        view: StatsView
    ) {
        self.repository = repository
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
        switch mode {
        case .week:
            view?.setHeader(to: selectedWeek.label)
            view?.showNextPrevButtons(
                showPrev: dataBuilder.canMoveWeekBackwards(selectedWeek),
                showNext: dataBuilder.canMoveWeekForward(selectedWeek)
            )

            let data = dataBuilder.weeklyStatsForWeek(selectedWeek, allStamps: stamps)
            view?.loadWeekData(
                header: WeekHeaderData(
                    weekdayHeaders: selectedWeek.weekdayLettersForWeek()),
                data: data)

        case .month:
            view?.setHeader(to: selectedMonth.label)
            view?.showNextPrevButtons(
                showPrev: dataBuilder.canMoveMonthBackwards(selectedMonth),
                showNext: dataBuilder.canMoveMonthForward(selectedMonth)
            )

            let data = dataBuilder.emptyStatsDataForMonth(selectedMonth, allStamps: stamps)
            view?.loadMonthData(data: data)
        }
    }
    
    // Move today's date one week to the past or one week to the future
    private func advancePeriod(by delta: Int) {
        switch mode {
        case .week:
            selectedWeek = CalendarHelper.Week(selectedWeek.firstDay.byAddingWeek(delta))
            
        case .month:
            selectedMonth = CalendarHelper.Month(selectedMonth.firstDay.byAddingMonth(delta))
        }
        
        // Update view
        loadViewData()
    }
}
