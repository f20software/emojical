//
//  StickerCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerCoordinator: StickerCoordinatorProtocol {

    // MARK: - DI

    private weak var parentController: UINavigationController?
    private var repository: DataRepository!

    init(
        parent: UINavigationController?,
        repository: DataRepository)
    {
        self.parentController = parent
        self.repository = repository
    }

    /// Shows modal form to create new goal
    func newGoal(with stickerId: Int64) {
        // Instantiate GoalViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Goal.initialViewController(),
              let view = nav.viewControllers.first as? GoalViewController else {
            assertionFailure("Failed to initialize GoalViewController")
            return
        }

        var goal = Goal.new
        goal.stamps = [stickerId]
        
        let coordinator = GoalCoordinator(
            parent: nav,
            repository: repository,
            awardManager: AwardManager.shared)
        
        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = GoalPresenter(
            view: view,
            coordinator: coordinator,
            awardManager: AwardManager.shared,
            repository: repository,
            goal: goal,
            presentation: .modal,
            editing: true
        )

        parentController?.present(nav, animated: true)
    }
}
