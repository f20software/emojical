//
//  StickersCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class StickersCoordinator: StickersCoordinatorProtocol {
    
    // MARK: - Private

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
        navigateToGoal2(goal)
    }

    /// Shows modal form to create new goal
    func newGoal() {
        navigateToGoal2(nil)
    }
    
    /// Push to edit sticker form
    func editSticker(_ sticker: Stamp) {
        navigateToSticker(sticker)
    }

    /// Shows modal form to create new sticker
    func newSticker() {
        navigateToSticker(nil)
    }

    // MARK: - Private helpers
    
    // Navigate to Goal edit / create screen - if `goal` object is passed will
    // push GoalViewController, otherwise - present as modal
    private func navigateToGoal2(_ goal: Goal?) {

        // Instantiate GoalViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Goal2.initialViewController(),
              let view = nav.viewControllers.first as? GoalViewController2 else {
            assertionFailure("Failed to initialize GoalViewController")
            return
        }

        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = GoalPresenter(
            view: view,
            awardManager: awardManager,
            repository: repository,
            goal: goal,
            presentation: goal == nil ? .modal : .push
        )

        if goal == nil {
            parentController?.present(nav, animated: true)
        } else {
            parentController?.pushViewController(view, animated: true)
        }
    }

    // Navigate to Goal edit / create screen - if `goal` object is passed will
    // push GoalViewController, otherwise - present as modal
    private func navigateToGoal(_ goal: Goal?) {

        // Instantiate GoalViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Goal.initialViewController(),
              let goalVC = nav.viewControllers.first as? GoalViewController else {
            assertionFailure("Failed to initialize GoalViewController")
            return
        }

        if let goal = goal {
            goalVC.title = goal.name
            goalVC.goal = goal
            goalVC.currentProgress = AwardManager.shared.currentProgressFor(goal)
            goalVC.presentationMode = .push
            parentController?.pushViewController(goalVC, animated: true)

        } else {
            goalVC.title = "New Goal"
            goalVC.goal = Goal(
                id: nil,
                name: "New Goal",
                period: .week,
                direction: .positive,
                limit: 5,
                stamps: []
            )
            goalVC.presentationMode = .modal
            parentController?.present(nav, animated: true)
        }
    }

    // Navigate to Sticker edit / create screen - if `sticker` object is passed will
    // push StickerViewController, otherwise - present as modal
    private func navigateToSticker(_ sticker: Stamp?) {
        // Instantiate GoalViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Sticker.initialViewController(),
              let stickerVC = nav.viewControllers.first as? StampViewController else {
            assertionFailure("Failed to initialize StampViewController")
            return
        }

        if let sticker = sticker {
            stickerVC.stamp = sticker
            stickerVC.presentationMode = .push
            parentController?.pushViewController(stickerVC, animated: true)
        } else {
            stickerVC.stamp = Stamp.defaultStamp
            stickerVC.presentationMode = .modal
            parentController?.present(nav, animated: true)
        }
    }
}
