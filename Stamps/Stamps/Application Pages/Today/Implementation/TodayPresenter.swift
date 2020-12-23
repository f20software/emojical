//
//  TodayPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
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
    private let goalsListener: GoalsListener
    private let calendar: CalendarHelper
    private let awardManager: AwardManager

    private weak var view: TodayView?
    private weak var coordinator: TodayCoordinator?

    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    // All available stamps (to be shown in stamp selector)
    private var allStamps: [Stamp] = []
    
    // Date header data for the week
    private var weekHeader: [DayHeaderData] = []
    
    // Days stickers data for the week
    private var dailyStickers: [[StickerData]] = []

    // Current stamps selected for the day
    private var selectedDayStickers = [Int64]()
    
    // Current awards
    private var awards = [Award]()
    
    // Current goals
    private var goals = [Goal]()
    
    // Current week index
    private var week = CalendarHelper.Week(Date()) {
        didSet {
            // Load data model from the repository
            weekHeader = week.dayHeadersForWeek()
            dailyStickers = dataBuilder.weekDataModel(for: week)
            awards = dataBuilder.awards(for: week)
            
            if week.isCurrentWeek {
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
            locked = untilToday < -Specs.editingBackDays || untilToday > Specs.editingForwardDays

            // Update current day stamps from the repository
            selectedDayStickers = repository.stampsIdsForDay(selectedDay)
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
            selectorState = locked ? .hidden :
                (selectedDay.isToday ? .fullSelector : .miniButton)
        }
    }
    
    // Stamp selector state
    private var selectorState: SelectorState = .hidden {
        didSet {
            view?.showStampSelector(selectorState)
        }
    }
    
    // To make sure we don't play sound on initial page load (when awards are updated)
    private var firstTime: Bool = true

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        awardsListener: AwardsListener,
        goalsListener: GoalsListener,
        awardManager: AwardManager,
        calendar: CalendarHelper,
        view: TodayView,
        coordinator: TodayCoordinator
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.awardsListener = awardsListener
        self.goalsListener = goalsListener
        self.awardManager = awardManager
        self.calendar = calendar
        self.view = view
        self.coordinator = coordinator
        
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

            let newAwards = self.dataBuilder.awards(for: self.week)
            if newAwards.count > self.awards.count {
                if self.firstTime {
                    self.firstTime = false
                } else {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }
            self.awards = newAwards
            self.loadAwardsData()
        })
        
        goalsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] awards in
            guard let self = self else { return }
            self.goals = self.repository.allGoals()
            self.loadAwardsData()
        })

        // Load set of all stamps
        allStamps = repository.allStamps()

        // Set current day and week
        selectedDay = Date()
        week = CalendarHelper.Week(selectedDay)
        let key = selectedDay.databaseKey
        selectedDayIndex = weekHeader.firstIndex(where: { $0.date.databaseKey == key }) ?? 0
        
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
        view?.onNewStickerTapped = { [weak self] in
            self?.coordinator?.newSticker()
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
        view?.onPlusButtonTapped = { [weak self] in
            if self?.locked == false {
                self?.selectorState = .fullSelector
            }
        }
        view?.onCloseStampSelectorTapped = { [weak self] in
            self?.selectorState = .miniButton
        }
    }
    
    private func loadViewData() {
        // Title and nav bar
        view?.setTitle(to: week.label)
        view?.showNextPrevButtons(
            showPrev: dataBuilder.canMoveBackward(week),
            showNext: dataBuilder.canMoveForward(week)
        )

        // Awards strip on the top
        loadAwardsData()
        
        // Column data
        view?.loadDaysData(header: weekHeader, daysData: dailyStickers)
        
        // Stamp selector data
        loadStampSelectorData()
        
        // Update selectors state based on the lock status
        view?.showStampSelector(selectorState)
    }
    
    private func loadStampSelectorData() {
        var data: [StampSelectorElement] = allStamps.compactMap({
            guard let id = $0.id else { return nil }
            return StampSelectorElement.stamp(
                StickerData(
                    stampId: id,
                    label: $0.label,
                    color: $0.color,
                    isUsed: selectedDayStickers.contains(id)
                )
            )
        })
        
        if data.count < 5 {
            data.append(.newStamp)
        }
        
        view?.loadStampSelectorData(data: data)
    }
    
    private func loadAwardsData() {
        var data = [GoalAwardData]()
            
        if week.isCurrentWeek {
            data = goals.compactMap({
                let stamp = repository.stampById($0.stamps.first)
                return GoalAwardData(
                    goal: $0,
                    progress: awardManager.currentProgressFor($0),
                    stamp: stamp
                )
            })
            // Put goals that are already reached in front
            data = data.sorted(by: { return $0 < $1 })
        } else {
            data = awards.compactMap({
                guard let goal = repository.goalById($0.goalId) else { return nil }
                let stamp = repository.stampById(goal.stamps.first)
                return GoalAwardData(
                    award: $0,
                    goal: goal,
                    stamp: stamp
                )
            })
        }

        view?.loadAwardsData(data: data)
        view?.showAwards(data.count > 0)
    }
    
    private func stampToggled(stampId: Int64) {
        guard locked == false else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            return
        }
        
        if selectedDayStickers.contains(stampId) {
            selectedDayStickers.removeAll { $0 == stampId }
        } else {
            selectedDayStickers.append(stampId)
        }
        
        // Update repository with stamps for today
        repository.setStampsForDay(selectedDay, stamps: selectedDayStickers)
        
        // Recalculate awards
        awardManager.recalculateAwards(selectedDay)
        
        // Reload the model and update the view
        weekHeader = week.dayHeadersForWeek()
        dailyStickers = dataBuilder.weekDataModel(for: week)
        loadViewData()
    }
    
    // Moving day within selected week
    private func selectDay(with index: Int) {
        selectedDayIndex = index
        selectedDay = weekHeader[index].date

        // Update view
        loadStampSelectorData()
    }
    
    // Move today's date one week to the past or one week to the future
    private func advanceWeek(by delta: Int) {
        guard delta == 1 || delta == -1 else { return }
        let next = (delta == 1)

        // When navigating week forward - select first day (Monday)
        // When navigating week back - select last day (Sunday)
        let dayDelta = next ? (7 - selectedDayIndex) : (-1 - selectedDayIndex)
        selectedDayIndex = next ? 0 : 6

        selectedDay = selectedDay.byAddingDays(dayDelta)
        week = CalendarHelper.Week(week.firstDay.byAddingWeek(delta))

        // Special logic of we're coming back to the current week
        // Select today's date
        if week.isCurrentWeek {
            selectedDay = Date()
            let key = selectedDay.databaseKey
            selectedDayIndex = weekHeader.firstIndex(where: { $0.date.databaseKey == key }) ?? 0
        }
        
        // Update view
        loadViewData()
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Editing days back from today (when it's further in the past - entries will become read-only)
    static let editingBackDays = 3

    /// Editing days forward from today (when it's further in the future - entries will become read-only)
    static let editingForwardDays = 3
}
