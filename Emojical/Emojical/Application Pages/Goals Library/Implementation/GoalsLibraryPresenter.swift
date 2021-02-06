//
//  GoalsLibraryPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/6/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class GoalsLibraryPresenter: GoalsLibraryPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private weak var view: GoalsLibraryView?
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        view: GoalsLibraryView
    ) {
        self.repository = repository
        self.view = view
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onGoalTapped = { [weak self] goalId in
//            guard let goal = self?.repository.goalById(goalId) else { return }
//            self?.coordinator?.editGoal(goal)
        }
        view?.onCancelTapped = { [weak self] in
            self?.view?.dismiss()
        }
    }
    
    private func loadViewData() {
        view?.updateTitle("goals_title".localized)
        
        let data = [
            GoalExampleData(category: "Health", name: "Play Soccer"),
            GoalExampleData(category: "Health", name: "Do Yoga"),
            GoalExampleData(category: "Health", name: "Be Active")
        ]
        
        view?.loadData(sections: ["Health"], goals: data)
    }
}
