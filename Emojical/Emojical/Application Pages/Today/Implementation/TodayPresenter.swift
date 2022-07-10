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
    private let coach: CoachListenerProtocol
    private let settings: LocalSettings
    private let main: MainCoordinatorProtocol?

    private weak var view: TodayView?
    private weak var coordinator: TodayCoordinatorProtocol?

    /// Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    // All available stamps (to be shown in sticker selector)
    private var allStickers: [Sticker] = []
    
    // Date header data for the week
    private var weekHeader: [DayHeaderData] = []
    
    // Days stickers data for the week
    private var dailyStickers: [[StickerData]] = []
    private var dailyStickersCount: Int {
        return dailyStickers.reduce(0, { $0 + $1.count })
    }

    // Current stamps selected for the day
    private var selectedDayStickers = [Int64]()
    
    // Current awards
    private var awards = [Award]()
    
    // Current goals
    private var goals = [Goal]()
    
    /// On the past weeks and on the weeks that don't have any stickers
    /// we will display speech bubble with ecouraging message, emoji face
    /// and on the past weeks list of received awards.
    ///
    /// For that we're adding two view and some data models to support them.
    /// See `recapBubbleView` and `emptyWeekBubbleView` and
    /// two data models - `recapBubbleData` and `emptyWeekBubbleData`

    // Data model to display recap bubble
    private var recapBubbleData: RecapBubbleData?

    // Data to display in empty week bubble
    private var emptyWeekBubbleData: EmptyWeekBubbleData?

    // Queue of messages that needs to be displayed
    private var messageQueue = OperationQueue()

    // Current week index
    private var week = CalendarHelper.Week(Date()) {
        didSet {
            // Load data model from the repository
            weekHeader = week.dayHeadersForWeek(highlightedIndex: selectedDayIndex)
            dailyStickers = dataBuilder.weekDataModel(for: week)
            awards = dataBuilder.awards(for: week)
            
            if week.isCurrentWeek {
                loadAndSortGoals()
            } else {
                goals = []
            }
        }
    }
    
    // Current date
    private var selectedDay = Date() {
        didSet {
            // Calculate distance from today and lock/unlock sticker selector
            let untilToday = Int(selectedDay.timeIntervalSince(calendar.today) / (60*60*24))
            locked = (untilToday > 0) ?
                // Selected day is in the future
                ((untilToday+1) > Specs.editingForwardDays) :
                // Selected day is in the past
                (untilToday < -Specs.editingBackDays)

            // Update current day stamps from the repository
            selectedDayStickers = repository.stampsIdsFor(day: selectedDay)
        }
    }

    // Currently selected day index
    private var selectedDayIndex: Int = -1 {
        didSet {
            weekHeader = week.dayHeadersForWeek(highlightedIndex: selectedDayIndex)
        }
    }
    
    // Lock out dates too far from today
    private var locked: Bool = false {
        didSet {
            let lastSelectorState = selectorState
            selectorState = locked ? .hidden :
                (lastSelectorState == .hidden ? .fullSelector : lastSelectorState)
            
        }
    }
    
    /// StickerSelector state
    private var selectorState: SelectorState = .hidden {
        didSet {
            view?.showStickerSelector(selectorState)
            
            // Update recap bubble visibility
            // - show only when selector or minibutton is not shown
            view?.loadRecapBubbleData(recapBubbleData, show: (selectorState == .hidden))
        }
    }
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        awardsListener: AwardsListener,
        goalsListener: GoalsListener,
        awardManager: AwardManager,
        coach: CoachListenerProtocol,
        calendar: CalendarHelper,
        settings: LocalSettings,
        view: TodayView,
        coordinator: TodayCoordinatorProtocol,
        main: MainCoordinatorProtocol?
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.awardsListener = awardsListener
        self.coach = coach
        self.goalsListener = goalsListener
        self.awardManager = awardManager
        self.calendar = calendar
        self.settings = settings
        self.view = view
        self.coordinator = coordinator
        self.main = main
        
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: calendar
        )
        
        // One message at a time
        self.messageQueue.maxConcurrentOperationCount = 1
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {

        // Configure listeners for the database
        setupListeners()

        // Initial data configuration for the current date
        initializeDataFor(date: calendar.today)
        
        // Configuring view according to the data
        setupView()
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
        messageQueue.isSuspended = false
    }
    
    /// Called when view about to disappear from the screen
    func onViewWillDisappear() {
        messageQueue.isSuspended = true
    }
    
    /// Navigate Today view to specific date
    func navigateTo(_ date: Date) {
        
        // Initialize data and load view
        initializeDataFor(date: date)
        loadViewData()
    }

    /// Show week recap for the specific date (any daty in a week will do)
    func showWeekRecapFor(_ date: Date) {

        // Initialize data and load view
        initializeDataFor(date: date)
        setupView()
        loadViewData()

        // Coordinator is responsible for navigating to the recap view
        coordinator?.showAwardsRecap(data: recapData())
    }

    /// Process single Coach message (could be onboarding message or cheers for reaching the goal or anything else)
    func showCoachMessage(_ message: CoachMessage, completion: (() -> Void)?) {
        NSLog("TodayPresenter: processMessage \(message)")
        guard let view = view else { return }

        // All message handling will require some kind of navigation.
        // Make sure we execute it in the main thread
        DispatchQueue.main.async {
            switch message {
            case .cheerGoalReached(let award):
                self.coordinator?.showCongratsWindow(data: award) {
                    completion?()
                }
            
            case .onboarding1:
                self.coordinator?.showOnboardingWindow(
                    message: message,
                    bottomMargin: view.stickerSelectorSize)
                {
                    completion?()
                    self.main?.navigateTo(.stickers)
                }
                
            case .onboarding2:
                self.coordinator?.showOnboardingWindow(
                    message: message,
                    bottomMargin: view.stickerSelectorSize) {
                    completion?()
                    self.main?.navigateTo(.goals)
                }

            case .weekReady(let message):
                self.coordinator?.showRecapReady(message: message) { [weak self] showRecap in
                    guard let self = self else { return }
                    if showRecap {
                        self.showWeekRecapFor(self.calendar.today.byAddingWeek(-1))
                    }
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Private helpers

    /// Reacting to significate time change event - updating data to current date and refreshing view
    @objc func significantTimeChange() {
        NSLog("TodayPresenter: Significant Time Change")
        
        // Initial data configuration for the current date
        initializeDataFor(date: calendar.today)
        
        // Configuring view according to the data
        setupView()
        loadViewData()
    }

    /// Initialize data objects based on the current date
    private func initializeDataFor(date: Date) {
        // Load set of all stamps
        allStickers = repository.allStamps().sorted(by: { $0.count > $1.count })

        // Set date and week objects
        selectedDay = date
        week = CalendarHelper.Week(date)
        
        let key = selectedDay.databaseKey
        selectedDayIndex = weekHeader.firstIndex(where: { $0.date.databaseKey == key }) ?? 0
    }
    
    
    /// Configure listeners to the data source changes
    private func setupListeners() {
        NSLog("TodayPresenter: setupListeners")

        // When stamps are updated
        stampsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            self?.initializeDataFor(date: self!.selectedDay)
            self?.loadStickerSelectorData()
        })
        
        // When awards are updated
        awardsListener.startListening(onChange: { [weak self] in
            guard let self = self else { return }
            self.awards = self.dataBuilder.awards(for: self.week)
            self.loadAwardsData()
        })
        
        // Subscribe to various cheeers and onboarding messages
        coach.startListening { message in
            self.messageQueue.addOperation(
                CoachMessageOperation(handler: self, message: message)
            )
        }
        
        // When goals are updated
        goalsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] in
            self?.loadAndSortGoals()
            self?.loadAwardsData()
        })

        // Subscribe to significant time change notification
        NotificationCenter.default.addObserver(self, selector: #selector(significantTimeChange),
            name: UIApplication.significantTimeChangeNotification, object: nil)
    }

    private func setupView() {
        
        // Subscribe to view callbacks
        view?.onStickerInSelectorTapped = { [weak self] stampId in
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
        view?.onCloseStickerSelector = { [weak self] in
            self?.selectorState = .miniButton
        }
        view?.onAwardTapped = { [weak self] index in
            guard let self = self else { return }
            
            // We should show recap window only for the past weeks
            // Presumably list of goals/awards on the top for the future will be empty,
            // so this callback won't be possible to call for the future weeks
            // Disabling current week should be enough.
            if self.week.isCurrentWeek {
                let goalIndexes = self.goals.compactMap({ $0.id })
                if goalIndexes.count > index {
                    if let goal = self.repository.goalBy(id: goalIndexes[index]) {
                        self.coordinator?.showGoal(goal)
                    }
                }
            }
        }
        view?.onRecapTapped = { [weak self] in
            guard let self = self else { return }
            
            // Sanity check - we should show recap window only for the past weeks
            if self.week.isPast {
                self.coordinator?.showAwardsRecap(data: self.recapData())
            }
        }
    }
    
    private func loadViewData() {
        // Title and nav bar
        view?.setTitle(to: week.label)
        view?.showNextPrevButtons(
            showPrev: dataBuilder.canMoveBackward(week),
            showNext: dataBuilder.canMoveForward(week)
        )

        // Awards strip on the top - only for the current week
        if week.isCurrentWeek && goals.count > 0 {
            loadAwardsData()
        } else {
            view?.showAwards(false)
        }
        
        // Week header data
        view?.loadWeekHeader(data: weekHeader)

        // Column data
        view?.loadDays(data: dailyStickers)

        // Recap bubble data will be built only for the past weeks
        recapBubbleData = buildRecapBubbleData()

        // Empty week bubble data will be built only for the weeks
        // where we don't have any stickers and don't already show Recap Bubble
        emptyWeekBubbleData = nil
        if recapBubbleData == nil {
            emptyWeekBubbleData = buildEmptyWeekBubbleData()
        }

        // Sticker selector data
        loadStickerSelectorData()

        // Update selectors state based on the lock status
        view?.showStickerSelector(selectorState)
        view?.loadRecapBubbleData(recapBubbleData, show: selectorState == .hidden)
        view?.loadEmptyWeekBubbleData(emptyWeekBubbleData)
    }
    
    /// Load view data model for the StickerSelector view
    private func loadStickerSelectorData() {
        let stickers: [StickerSelectorElement] = allStickers.compactMap({
            guard let id = $0.id else { return nil }
            return StickerSelectorElement.stamp(
                StickerData(
                    stampId: id,
                    label: $0.label,
                    color: $0.color,
                    isUsed: selectedDayStickers.contains(id)
                )
            )
        })
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:
            Bundle.main.preferredLocalizations.first ?? "en")
        formatter.dateFormat = "EEEE"
        
        view?.loadStickerSelector(data: StickerSelectorData(
            selectedDay: formatter.string(from: selectedDay),
            stickers: stickers)
        )
    }
    
    private func recapData() -> [AwardRecapData] {
        return awards.compactMap({
            guard let goal = repository.goalBy(id: $0.goalId) else { return nil }

            return AwardRecapData(
                title: $0.descriptionText,
                progress: GoalOrAwardIconData(
                    award: $0,
                    goal: goal,
                    stamp: goal.stickers.first
                )
            )
        })
    }
    
    // Emoji to be shown depend on how well user reached their goals
    private func emojiImageForReachedGoals(total: Int, reached: Int) -> UIImage {
        if reached == 0 {
            return Specs.emojicalPointFinger
        } else if reached == total {
            return Specs.emojicalTwoThumbsUp
        }
        
        return Specs.emojicalOk
    }
    
    // Build data required to display recap bubble
    private func buildRecapBubbleData() -> RecapBubbleData? {
        
        // No need to show recap bubble if it's not the past
        guard week.isPast else { return nil }
        
        // No need to show recap bubble if we didn't have any stickers that week
        guard dailyStickersCount > 0 else { return nil }

        let awards = dataBuilder.awards(for: week)
        let totalCount = awards.count
        let reachedCount = awards.filter({ $0.reached }).count
        
        return RecapBubbleData(
            message: Language.weekRecapForGoals(total: totalCount, reached: reachedCount),
            icons: awards.compactMap {
                guard $0.reached else { return nil }
                guard let goal = repository.goalBy(id: $0.goalId) else { return nil }
                return AwardIconData(goal: goal)
            },
            faceImage: emojiImageForReachedGoals(total: totalCount, reached: reachedCount)
        )
    }
    
    // Build data required to display recap bubble
    private func buildEmptyWeekBubbleData() -> EmptyWeekBubbleData? {

        // First off - we have some stickers - don't show anything, return nil
        guard dailyStickersCount == 0 else { return nil }

        // If user hasn't seen onboarding screen - it will be shown, don't show bubble
        guard settings.isOnboardingSeen(.onboarding1) else { return nil }
        
        if week.isCurrentWeek {
            return EmptyWeekBubbleData(
                message: "empty_current_week".localized,
                faceImage: Specs.emojicalTwoThumbsUp
            )
        } else if week.isPast {
            return EmptyWeekBubbleData(
                message: "empty_past_week".localized,
                faceImage: Specs.emojicalSad
            )
        } else if week.isFuture {
            return EmptyWeekBubbleData(
                message: "empty_future_week".localized,
                faceImage: Specs.emojicalSmile
            )
        }
        
        return nil
    }

    private func loadAndSortGoals() {
        let allGoals = repository.allGoals().sorted(by: { $0 < $1 })
        goals =
            allGoals.filter({
                $0.isReached(progress: awardManager.currentProgressFor($0)) == true }) +
            allGoals.filter({
                $0.isReached(progress: awardManager.currentProgressFor($0)) == false })
        
        // Need to filter out non-periodic goals that were already reached in the past
        goals = goals.compactMap({
            if $0.isPeriodic == false {
                let history = dataBuilder.historyFor(goal: $0.id, limit: 12)
                if history != nil &&
                    history!.reached.count > 0 &&
                    history!.reached.lastUsed ?? week.lastDay < week.firstDay {
                    return nil
                }
            }
            
            return $0
        })
    }
    
    private func loadAwardsData() {
        guard week.isCurrentWeek else { return }

        var data = [GoalOrAwardIconData]()
        data = goals.compactMap({
            return GoalOrAwardIconData(
                goal: $0,
                progress: awardManager.currentProgressFor($0)
            )
        })

        view?.showAwards(true)
        view?.loadAwards(data: data)
    }
    
    private func stampToggled(stampId: Int64) {
        guard locked == false else {
            return
        }
        
        // TODO: Refactor sound support
        // AudioServicesPlaySystemSound(1105)
            
        if selectedDayStickers.contains(stampId) {
            selectedDayStickers.removeAll { $0 == stampId }
        } else {
            selectedDayStickers.append(stampId)
        }
        
        // Update repository with stamps for today
        repository.setStampsForDay(selectedDay, stamps: selectedDayStickers)
        
        // Recalculate awards
        awardManager.recalculateAwards(selectedDay)
        
        // TODO: Optimize to use listener approach
        if calendar.isDateToday(selectedDay) {
            NotificationCenter.default.post(name: .todayStickersUpdated, object: nil)
        }
        
        // Reload the model and update the view
        dailyStickers = dataBuilder.weekDataModel(for: week)
        loadViewData()
    }
    
    // Moving day within selected week
    private func selectDay(with index: Int) {
        selectedDayIndex = index
        selectedDay = weekHeader[index].date

        // Update view
        view?.loadWeekHeader(data: weekHeader)
        loadStickerSelectorData()
    }
    
    // Move today's date one week to the past or one week to the future
    private func advanceWeek(by delta: Int) {
        guard delta == 1 || delta == -1 else { return }

        // Always select Monday
        selectedDayIndex = 0
        week = CalendarHelper.Week(week.firstDay.byAddingWeek(delta))
        selectedDay = week.firstDay

        // Special logic of we're coming back to the current week
        // Select today's date
        if week.isCurrentWeek {
            selectedDay = calendar.today
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
    static let editingBackDays = 2

    /// Editing days forward from today (when it's further in the future - entries will become read-only)
    static let editingForwardDays = 2

    /// Emoji size to be cached
    static let emojiSize = CGSize(width: 100, height: 100)
    
    /// Image to be dsiplayed on recap bubble when user did good job
    static let emojicalOk = UIImage(named: "emojical-ok")!.resized(to: emojiSize)
    
    /// Image to be dsiplayed on recap bubble when user failed to reach any goals
    static let emojicalPointFinger = UIImage(named: "emojical-point")!.resized(to: emojiSize)
    
    /// Image to be dsiplayed on recap bubble when user reached all goals
    static let emojicalTwoThumbsUp = UIImage(named: "emojical-two-thumbs")!.resized(to: emojiSize)

    /// Image to be dsiplayed on recap bubble there was no activity
    static let emojicalSad = UIImage(named: "emojical-sad")!.resized(to: emojiSize)

    /// Image to be dsiplayed on recap bubble for the future
    static let emojicalSmile = UIImage(named: "emojical-smiley")!.resized(to: emojiSize)
}
