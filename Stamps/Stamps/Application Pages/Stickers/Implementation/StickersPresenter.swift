//
//  StickersPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class StickersPresenter: StickersPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let stampsListener: StampsListener
    private let goalsListener: GoalsListener
    private let awardsListener: AwardsListener
    private let awardManager: AwardManager
    
    private weak var view: StickersView?
    private weak var coordinator: StickersCoordinator?
    
    // MARK: - State

    // View model data for all stamps
    private var stampsData: [DayStampData] = []
    
    // View model data for all goals
    private var goalsData: [GoalAwardData] = []
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        goalsListener: GoalsListener,
        awardsListener: AwardsListener,
        awardManager: AwardManager,
        view: StickersView,
        coordinator: StickersCoordinator
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.goalsListener = goalsListener
        self.awardsListener = awardsListener
        self.awardManager = awardManager
        self.view = view
        self.coordinator = coordinator
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
        
        // Subscribe to stamp listener in case stamps array ever changes
        stampsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            self?.loadViewData()
        })

        // Subscribe to goals listener in case stamps array ever changes
        goalsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            self?.loadViewData()
        })

        // Subscribe to awards listener for when new award is given
        // (to update list of goals including badges)
        awardsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] awards in
            self?.loadViewData()
        })
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onGoalTapped = { [weak self] goalId in
            self?.coordinator?.editGoal(goalId)
        }
        view?.onNewGoalTapped = { [weak self] in
            self?.coordinator?.newGoal()
        }
        view?.onStickerTapped = { [weak self] stickerId in
            self?.coordinator?.editSticker(stickerId)
        }
        view?.onNewStickerTapped = { [weak self] in
            self?.coordinator?.newSticker()
        }
    }
    
    private func loadViewData() {
        let newStampsData = repository.allStamps().map({
            DayStampData(
                stampId: $0.id,
                label: $0.label,
                color: $0.color,
                isUsed: false
            )
        })
        
        let newGoalsData: [GoalAwardData] = repository.allGoals().compactMap({
            guard let goalId = $0.id else { return nil }

            let progress = self.awardManager.currentProgressFor($0)
            let firstStamp = self.repository.stampById($0.stamps[0])
            let goalReached = progress >= $0.limit

            return GoalAwardData(
                goalId: goalId,
                name: $0.name,
                details: $0.details,
                count: $0.count,
                color: goalReached ? repository.colorForGoal(goalId) : UIColor.systemGray.withAlphaComponent(0.2),
                emoji: firstStamp?.label,
                dashes: $0.period == .month ? 0 : 7,
                progress: goalReached ? 1.0 : CGFloat(progress) / CGFloat($0.limit),
                progressColor: $0.direction == .positive ?
                    (goalReached ? UIColor.positiveGoalReached : UIColor.positiveGoalNotReached) :
                    (goalReached ? UIColor.negativeGoalReached : UIColor.negativeGoalNotReached)
                
            )
        })
        
        var updated = false
        if stampsData != newStampsData {
            stampsData = newStampsData
            updated = true
        }
        if goalsData != newGoalsData {
            goalsData = newGoalsData
            updated = true
        }

        if updated {
            view?.loadData(stickers: stampsData, goals: goalsData)
        }
    }
}
