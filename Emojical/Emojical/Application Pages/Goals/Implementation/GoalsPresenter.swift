//
//  GoalsPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class GoalsPresenter: GoalsPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let stampsListener: StampsListener
    private let goalsListener: GoalsListener
    private let awardsListener: AwardsListener
    private let awardManager: AwardManager
    
    private weak var view: GoalsView?
    private weak var coordinator: GoalsCoordinatorProtocol?
    
    // MARK: - State

    // View model data for all goals
    private var goalsData: [GoalData]?
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        goalsListener: GoalsListener,
        awardsListener: AwardsListener,
        awardManager: AwardManager,
        view: GoalsView,
        coordinator: GoalsCoordinatorProtocol
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
            guard let goal = self?.repository.goalBy(id: goalId) else { return }
            self?.coordinator?.editGoal(goal)
        }
        view?.onNewGoalTapped = { [weak self] in
            self?.coordinator?.newGoal()
        }
        view?.onAddButtonTapped = { [weak self] in
            self?.confirmAddAction()
        }
        view?.onGoalsExamplesTapped = { [weak self] in
            self?.coordinator?.newGoalFromExamples()
        }
    }
    
    private func loadViewData() {
        view?.updateTitle("goals_tab_title".localized)
        let newGoalsData: [GoalData] = repository.allGoals().compactMap({
            guard let goalId = $0.id else { return nil }

            let stamp = self.repository.stampBy(id: $0.stamps.first)
            return GoalData(
                goalId: goalId,
                name: $0.name,
                period: $0.period,
                details: Language.goalDescription($0, includePeriod: false),
                count: $0.count,
                checkMark: $0.count > 0 && $0.isPeriodic == false,
                icon: GoalOrAwardIconData(
                    stamp: stamp,
                    goal: $0,
                    progress: self.awardManager.currentProgressFor($0)
                )
            )
        })
        
        var updated = false
        if goalsData != newGoalsData {
            goalsData = newGoalsData
            updated = true
        }

        if updated && goalsData != nil {
            view?.loadData(goals: goalsData!)
        }
    }
    
    private func confirmAddAction() {
        let confirm = UIAlertController(
            title: "create_new_title".localized, message: nil, preferredStyle: .actionSheet
        )
        
        confirm.addAction(
            UIAlertAction(title: "goal_title".localized, style: .default, handler: { (_) in
                self.coordinator?.newGoal()
            })
        )
        confirm.addAction(
            UIAlertAction(title: "create_goal_from_examples_title".localized, style: .default, handler: { (_) in
                self.coordinator?.newGoalFromExamples()
            })
        )
        confirm.addAction(
            UIAlertAction(title: "dismiss_button".localized, style: .cancel, handler: { (_) in
                confirm.dismiss(animated: true, completion: nil)
            })
        )
        view?.viewController?.present(confirm, animated: true, completion: nil)
    }
}
