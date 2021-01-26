//
//  StickersCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

enum PresentationMode {
    /// Modal presentation - editing new goal initially
    case modal
    /// Push presentation - viewing goal initially, can switch to edit mode
    case push
}

enum ViewMode {
    /// Form is in view mode
    case view
    /// Form is in edit mode
    case edit
}

class StickersCoordinator: StickersCoordinatorProtocol {
    
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
    
    /// Push to edit sticker form
    func editSticker(_ sticker: Stamp) {
        navigateToSticker(mode: .push, sticker: sticker)
    }

    /// Shows modal form to create new sticker
    func newSticker() {
        navigateToSticker(mode: .modal, sticker: nil)
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

        let coordinator = GoalCoordinator(
            parent: mode == .modal ? nav : parentController,
            repository: repository,
            awardManager: awardManager)
        
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

    // Navigate to Sticker edit / create screen - if `goal` object is passed will
    // push StickerViewController, otherwise - present as modal
    private func navigateToSticker(mode: PresentationMode, sticker: Stamp?) {

        // Instantiate StickerViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Sticker.initialViewController(),
              let view = nav.viewControllers.first as? StickerViewController else {
            assertionFailure("Failed to initialize StickerViewController")
            return
        }

        let coordinator = StickerCoordinator(
            parent: mode == .modal ? nav : parentController,
            repository: repository)
        
        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = StickerPresenter(
            view: view,
            coordinator: coordinator,
            awardManager: awardManager,
            repository: repository,
            sticker: sticker,
            presentation: mode
        )

        switch mode {
        case .modal:
            parentController?.present(nav, animated: true)
        case .push:
            parentController?.pushViewController(view, animated: true)
        }
    }
}
