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
    private weak var coordinator: StickersCoordinatorProtocol?
    
    // MARK: - State

    // View model data for all stamps
    private var stampsData: [StickerData] = []
    
    // View model data for all goals
    private var goalsData: [GoalData] = []
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        goalsListener: GoalsListener,
        awardsListener: AwardsListener,
        awardManager: AwardManager,
        view: StickersView,
        coordinator: StickersCoordinatorProtocol
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
        awardsListener.startListening(onChange: { [weak self] in
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
            guard let goal = self?.repository.goalById(goalId) else { return }
            self?.coordinator?.editGoal(goal)
        }
        view?.onNewGoalTapped = { [weak self] in
            self?.coordinator?.newGoal()
        }
        view?.onStickerTapped = { [weak self] stickerId in
            guard let sticker = self?.repository.stampById(stickerId) else { return }
            self?.coordinator?.editSticker(sticker)
        }
        view?.onNewStickerTapped = { [weak self] in
            self?.coordinator?.newSticker()
        }
        view?.onAddButtonTapped = { [weak self] in
            self?.confirmAddAction()
        }
    }
    
    private func loadViewData() {
        let newStampsData = repository.allStamps().map({
            StickerData(
                stampId: $0.id,
                label: $0.label,
                color: $0.color,
                isUsed: false
            )
        })
        
        let newGoalsData: [GoalData] = repository.allGoals().compactMap({
            guard let goalId = $0.id else { return nil }

            let stamp = self.repository.stampById($0.stamps.first)
            return GoalData(
                goalId: goalId,
                name: $0.name,
                details: $0.details,
                count: $0.count,
                progress: GoalAwardData(
                    goal: $0,
                    progress: self.awardManager.currentProgressFor($0),
                    stamp: stamp
                )
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
    
    private func confirmAddAction() {
        let confirm = UIAlertController(title: "Create New...", message: nil, preferredStyle: .actionSheet)
        confirm.addAction(UIAlertAction(title: "Sticker", style: .default, handler: { (_) in
            self.coordinator?.newSticker()
        }))
        confirm.addAction(UIAlertAction(title: "Goal", style: .default, handler: { (_) in
            self.coordinator?.newGoal()
        }))
        confirm.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            confirm.dismiss(animated: true, completion: nil)
        }))
        (view as! UIViewController).present(confirm, animated: true, completion: nil)
    }

}
