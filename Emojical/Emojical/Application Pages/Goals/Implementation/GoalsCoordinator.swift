//
//  GoalsCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalsCoordinator: GoalsCoordinatorProtocol {
    
    // MARK: - DI

    private weak var parentController: UINavigationController?
    private let repository: DataRepository
    private let awardManager: AwardManager

    init(
        parent: UINavigationController,
        repository: DataRepository,
        awardManager: AwardManager)
    {
        self.parentController = parent
        self.repository = repository
        self.awardManager = awardManager
    }

    /// Push to edit goal form
    func editGoal(_ goal: Goal) {
        navigateToGoal(mode: .push, goal: goal)
    }

    /// Shows modal form to create new goal
    func newGoal() {
        navigateToGoal(mode: .modal, goal: nil)
    }
    
    /// Shows modal form to select a goal from example library
    func newGoalFromExamples() {
        navigateToGoalsLibrary()
    }


    // MARK: - Private helpers
    
    // Navigate to Goal edit / create screen - if `goal` object is passed will
    // push GoalViewController, otherwise - present as modal
    private func navigateToGoal(mode: PresentationMode, goal: Goal?) {

        // Instantiate GoalViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Goal.initialViewController(),
              let view = nav.viewControllers.first as? GoalViewController else {
            assertionFailure("Failed to initialize GoalViewController")
            return
        }

        let coordinator = GoalCoordinator(parent: mode == .modal ? nav : parentController)
        
        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = GoalPresenter(
            view: view,
            coordinator: coordinator,
            awardManager: awardManager,
            repository: repository,
            goal: goal,
            presentation: mode,
            editing: (goal == nil)
        )

        switch mode {
        case .modal:
            parentController?.present(nav, animated: true)
        case .push:
            parentController?.pushViewController(view, animated: true)
        }
    }

    // Navigate to Select Goal from Examples screen
    private func navigateToGoalsLibrary() {

        // Instantiate GoalsLibraryViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.GoalsLibrary.initialViewController(),
              let view = nav.viewControllers.first as? GoalsLibraryViewController else {
            assertionFailure("Failed to initialize GoalsLibraryViewController")
            return
        }

        view.presenter = GoalsLibraryPresenter(
            repository: Storage.shared.repository,
            view: view
        )
        
        parentController?.present(nav, animated: true)
    }
}
