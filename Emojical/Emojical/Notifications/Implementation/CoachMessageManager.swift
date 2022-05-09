//
//  CoachMessageManager.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

class CoachMessageManager {
    
    /// Singleton instance
    static var shared: CoachProtocol! {
        willSet {
            if shared != nil {
                assertionFailure("CoachMessageManager should be initialized once per application launch")
            }
        }
    }

    // MARK: - DI

    /// Database award listener
    private var awardListener: AwardsListener!

    /// Data repository
    private var repository: DataRepository!

    /// Diary listener
    private var diaryListener: DiaryListener!

    /// Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder
    
    /// Private reference to the LocalSettings object
    private let settings: LocalSettings

    // MARK: - Internal state
    
    /// List of observers for awards change notification
    private var onShowObservers = ObserverList<((CoachMessage) -> Void)>()
    
    /// Internal queue to ensure that work with observers is done in a thread safe way
    private var queue: DispatchQueue!
    
    /// Hold to current week to understand when new award for current week is created
    private var currentWeek = CalendarHelper.Week(Date())
    
    /// List of awards for the current week
    private var awards = [Award]()

    init(
        awardListener: AwardsListener,
        repository: DataRepository
    ) {

        self.awardListener = awardListener
        self.repository = repository
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: CalendarHelper.shared
        )
        self.diaryListener = Storage.shared.diaryListener()
        self.settings = LocalSettings.shared

        queue = DispatchQueue(label: "com.svidersky.Emojical.coach")
        awards = dataBuilder.awards(for: currentWeek)
            
        configureListeners()
    }

    // MARK: - Private helpers

    // Subscribe to changes in the database
    private func configureListeners() {
        // Subscribe to changes in Awards
        awardListener.startListening { [weak self] in
            self?.checkAwards()
        }

        diaryListener.startListening { [weak self] count in
            self?.checkDiary()
        }
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(weekReady), name: .weekClosed, object: nil)
    }
    
    private func notifyObservers(message: CoachMessage) {
        NSLog("CoachMessageManager: notifyObservers [\(onShowObservers.isEmpty)] \(message)")
        onShowObservers.forEach { observer in
            observer(message)
        }
    }
    
    @objc private func weekReady() {
        NSLog("CoachMessageManager: weekReady")

        let awards = dataBuilder.awards(for: CalendarHelper.Week(Date().byAddingWeek(-1)))
        let totalCount = awards.count
        if totalCount == 0 {
            return
        }

        let reachedCount = awards.filter({ $0.reached }).count
        let message = Language.weekRecapForGoals(total: totalCount, reached: reachedCount)

        notifyObservers(message: .weekReady(message))
    }
    
    /// Check whether new awards given for the goals that just reached
    private func checkAwards() {
        NSLog("CoachMessageManager: checkNewAwards")

        let new = dataBuilder.awards(for: currentWeek)
        let needCongratulate = new
            .filter({ $0.reached == true })
            .filter { award in
                return (self.awards.contains(where: {
                $0.reached == award.reached && $0.goalId == award.goalId
            }) == false)
        }
        awards = new

        guard needCongratulate.count > 0 else { return }
        
        needCongratulate.forEach({
            self.notifyObservers(message:
                .cheerGoalReached($0)
            )
        })
    }
    
    /// Check the status of the Diary database to decide whether we need to show onboarding messages
    private func checkDiary() {
        let total = repository.allDiaryCount()
        
        if total == 0 {
            if !settings.isOnboardingSeen(.onboarding1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.notifyObservers(message: .onboarding1)
                    self.settings.seenOnboarding(.onboarding1)
                }
            }
            return
        }
        
        if total == 2 {
            if !settings.isOnboardingSeen(.onboarding2) {
                notifyObservers(message: .onboarding2)
                settings.seenOnboarding(.onboarding2)
            }
            return
        }
    }
}

extension CoachMessageManager: CoachProtocol {
    
    /// Add observer for Coach messages
    func addObserver(_ disposable: AnyObject, onShow: @escaping (CoachMessage) -> Void) {
        NSLog("CoachMessageManager: addObserver \(String(describing: onShow))")
        queue.async { [weak self] in
            self?.onShowObservers.addObserver(disposable, onShow)
        }
    }

    /// Remove observer for Coach messages
    func removeObserver(_ disposable: AnyObject) {
        queue.async { [weak self] in
            self?.onShowObservers.removeObserver(disposable)
        }
    }

    /// Coach listener instance
    func coachListener() -> CoachListener {
        return CoachListener(source: self)
    }

    /// Testing various messages sent by CoachMessageManager
    func mockMessage(_ message: CoachMessage) {
        notifyObservers(message: message)
        settings.seenOnboarding(message)
    }
}
