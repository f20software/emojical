//
//  TodayPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/6/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class TodayPresenter: TodayPresenterProtocol {

    // MARK: - DI

    let repository: DataRepository
    let calendar: CalendarHelper
    weak var view: TodayView?

    // MARK: - State

    // Stamps and data header for each day
    private var model: [DayColumnData] = []

    // Current stamps selected for the day
    private var currentStamps = [Int64]()

    // Current week index
    private var weekIndex: Int?
    
    // Current date
    private var today = Date()

    // Currently selected day index
    private var selectedDay = 0

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        calendar: CalendarHelper,
        view: TodayView
    ) {
        self.repository = repository
        self.calendar = calendar
        self.view = view
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        
        today = Date(year: 2020, month: 12, day: 4)
        weekIndex = calendar.weekIndexForDay(date: today)

        if let wi = weekIndex {
            model = CalendarDataBuilder(repository: repository, calendar: calendar).weekDataForWeek(wi)
            let key = today.databaseKey
            selectedDay = model.firstIndex(where: { $0.header.date.databaseKey == key }) ?? 0
        }
        
        currentStamps = repository.stampsIdsForDay(today)
        setupView()
    }
    
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onStampInSelectorTapped = { [weak self] stampId in
            self?.stampToggled(stampId: stampId)
        }
        view?.onDayHeaderTapped = { [weak self] index in
            self?.selectDay(with: index)
        }
    }
    
    private func loadViewData() {
        // Column data
        view?.loadDaysData(data: model)
        
        // Stamp selector data
        loadStampSelectorData()
    }
    
    private func loadStampSelectorData() {
        let allStamps = repository.allStamps()
        let data: [DayStampData] = allStamps.compactMap({
            guard let id = $0.id else { return nil }
            return DayStampData(
                stampId: id,
                label: $0.label,
                color: $0.color,
                isEnabled: currentStamps.contains(id) == false)
        })
        view?.loadStampSelectorData(data: data)
    }
    
    private func stampToggled(stampId: Int64) {
        if currentStamps.contains(stampId) {
            currentStamps.removeAll { $0 == stampId }
        } else {
            currentStamps.append(stampId)
        }
        
        loadStampSelectorData()
    }
    
    private func selectDay(with index: Int) {
        guard let wi = weekIndex else { return }
        today = calendar.currentWeeks[wi].firstDay.byAddingDays(index)
        
        // Reload current day stamps and stamp selector
        currentStamps = repository.stampsIdsForDay(today)
        loadStampSelectorData()
    }
}
