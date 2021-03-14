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

    /// Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

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

        queue = DispatchQueue(label: "com.svidersky.Emojical.coach")
        awards = dataBuilder.awards(for: currentWeek)
            
        configureListeners()
        initialStatusCheck()
    }

    // MARK: - Observers
    
    func addValetObserver(_ disposable: AnyObject, onShow: @escaping (CoachMessage) -> Void) {
        queue.async { [weak self] in
            self?.onShowObservers.addObserver(disposable, onShow)
        }
    }

    func removeValetObserver(_ disposable: AnyObject) {
        queue.async { [weak self] in
            self?.onShowObservers.removeObserver(disposable)
        }
    }

    // MARK: - Private helpers

    // Subscribe to changes in the database
    private func configureListeners() {
        // Subscribe to changes in Awards
        awardListener.startListening { [weak self] in
            self?.checkNewAwards()
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(weekReady), name: .weekClosed, object: nil)
    }
    
    private func notifyObservers(message: CoachMessage) {
        NSLog("ValetManager: notifyObservers [\(onShowObservers.isEmpty)] \(message)")
        onShowObservers.forEach { observer in
            observer(message)
        }
    }
    
    @objc private func weekReady() {
        NSLog("ValetManager: weekReady")

        let awards = dataBuilder.awards(for: CalendarHelper.Week(Date().byAddingWeek(-1)))
        let totalCount = awards.count
        if totalCount == 0 {
            return
        }

        let reachedCount = awards.filter({ $0.reached }).count
        let message = Language.weekRecapForGoals(total: totalCount, reached: reachedCount)

        notifyObservers(message: .weekReady(message))
    }
    
    // Check whether new awards given for the goals that just reached
    private func checkNewAwards() {
        NSLog("ValetManager: checkNewAwards")

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
    
    private func initialStatusCheck() {
        // If we don't have any diary records (i.e. app launched probably first time
        // generate event to show first onboarding message
        if repository.getFirstDiaryDate() == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.notifyObservers(message: .onboarding1)
            })
        }
    }
}

extension CoachMessageManager: CoachProtocol {
    
    /// Coach listener instance
    func coachListener() -> CoachListener {
        return CoachListener(source: self)
    }

    /// Testing various messages sent by CoachMessageManager
    func mockMessage(_ message: CoachMessage) {
        notifyObservers(message: message)
    }
}
