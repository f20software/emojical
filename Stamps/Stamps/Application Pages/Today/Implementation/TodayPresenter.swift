//
//  TodayPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/6/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class TodayPresenter: TodayPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let stampsListener: StampsListener
    private let awardsListener: AwardsListener
    private let calendar: CalendarHelper
    private let awardManager: AwardManager
    private weak var view: TodayView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    // All available stamps (to be shown in stamp selector)
    private var allStamps: [Stamp] = []
    
    // Stamps and data headers for the whole week
    private var model: [DayColumnData] = []

    // Current stamps selected for the day
    private var currentStamps = [Int64]()
    
    // Current awards
    private var awards = [Award]()
    
    // Current goals
    private var goals = [Goal]()

    // Current week index
    private var weekIndex: Int = 0 {
        didSet {
            // Load data model from the repository
            model = dataBuilder.weekDataForWeek(weekIndex)
            awards = dataBuilder.awardsForWeek(weekIndex)
            
            if calendar.currentWeeks[weekIndex].isCurrentWeek {
                goals = repository.allGoals()
            } else {
                goals = []
            }
        }
    }
    
    // Current date
    private var selectedDay = Date() {
        didSet {
            // Calculate distance from today and lock/unlock stamp selector
            let untilToday = Int(selectedDay.timeIntervalSince(Date()) / (60*60*24))
            locked = untilToday < -6 || untilToday > 6

            // Update current day stamps from the repository
            currentStamps = repository.stampsIdsForDay(selectedDay)
        }
    }

    // Currently selected day index
    private var selectedDayIndex = 0 {
        didSet {
            view?.setSelectedDay(to: selectedDayIndex)
        }
    }
    
    // Lock out dates too far from today
    private var locked: Bool = false {
        didSet {
            view?.showLock(locked)
        }
    }

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        awardsListener: AwardsListener,
        awardManager: AwardManager,
        calendar: CalendarHelper,
        view: TodayView
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.awardsListener = awardsListener
        self.awardManager = awardManager
        self.calendar = calendar
        self.view = view
        
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: calendar
        )
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        
        stampsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            guard let self = self else { return }
            
            self.allStamps = self.repository.allStamps()
            self.loadStampSelectorData()
        })
        
        awardsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] awards in
            guard let self = self else { return }
            
            self.awards = self.dataBuilder.awardsForWeek(self.weekIndex)
            self.loadAwardsData()
        })


        // Load set of all stamps
        allStamps = repository.allStamps()

        // Set current day and week
        selectedDay = Date()
        weekIndex = calendar.weekIndexForDay(date: selectedDay) ?? 0

        let key = selectedDay.databaseKey
        selectedDayIndex = model.firstIndex(where: { $0.header.date.databaseKey == key }) ?? 0
        
        setupView()
    }
    
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        
        // Subscribe to view callbacks
        view?.onStampInSelectorTapped = { [weak self] stampId in
            self?.stampToggled(stampId: stampId)
        }
        view?.onDayHeaderTapped = { [weak self] index in
            self?.selectDay(with: index)
        }
        view?.onNextWeekTapped = { [weak self] in
            self?.advanceWeek(by: 1)
        }
        view?.onPrevWeekTapped = { [weak self] in
            self?.advanceWeek(by: -1)
        }
    }
    
    private func loadViewData() {
        // Title and nav bar
        view?.setTitle(to: dataBuilder.weekTitleForWeek(weekIndex))
        view?.showNextWeekButton(weekIndex < (calendar.currentWeeks.count-1))
        view?.showPrevWeekButton(weekIndex > 0)

        // Awards strip on the top
        loadAwardsData()
        
        // Column data
        view?.loadDaysData(data: model)
        
        // Stamp selector data
        loadStampSelectorData()
    }
    
    private func loadStampSelectorData() {
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
    
    private func loadAwardsData() {
        let currentWeek = calendar.currentWeeks[weekIndex].isCurrentWeek
        
        if currentWeek {
            view?.loadAwardsData(data: goals.compactMap({
                guard let goalId = $0.id else { return nil }
                
                let progress = self.awardManager.currentProgressFor($0)
                return TodayAwardData(
                    goalId: goalId,
                    color: progress >= $0.limit ? repository.colorForGoal(goalId) : UIColor.systemGray,
                    dashes: $0.period == .month ? 0 : 7
                )
            }))
        } else {
            view?.loadAwardsData(data: awards.compactMap({
                guard let goal = repository.goalById($0.goalId),
                      let goalId = goal.id else { return nil }
                
                return TodayAwardData(
                    goalId: goalId,
                    color: repository.colorForAward($0),
                    dashes: goal.period  == .month ? 0 : 7
                )
            }))
        }
    }
    
    private func stampToggled(stampId: Int64) {
        if locked {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            return
        }
        
        if currentStamps.contains(stampId) {
            currentStamps.removeAll { $0 == stampId }
        } else {
            currentStamps.append(stampId)
        }
        
        // Update repository with stamps for today
        repository.setStampsForDay(selectedDay, stamps: currentStamps)
        
        // Recalculate awards
        awardManager.recalculateAwards(selectedDay)
        
        // Reload the model and update the view
        model = dataBuilder.weekDataForWeek(weekIndex)
        
        loadViewData()
    }
    
    // Moving day within selected week
    private func selectDay(with index: Int) {
        selectedDayIndex = index
        selectedDay = model[index].header.date

        // Update view
        loadStampSelectorData()
    }
    
    // Move today's date one week to the past or one week to the future
    private func advanceWeek(by delta: Int) {
        guard delta == 1 || delta == -1 else { return }
        let next = (delta == 1)

        
        let dayDelta = next ? (7 - selectedDayIndex) : (-1 - selectedDayIndex)
        selectedDayIndex = next ? 0 : 6

        selectedDay = selectedDay.byAddingDays(dayDelta)
        weekIndex = weekIndex + delta

        // Update view
        loadViewData()
    }
}
