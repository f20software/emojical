//
//  TodayCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class TodayCoordinator: TodayCoordinatorProtocol {
    
    // MARK: - DI

    private weak var parentController: UINavigationController?

    init(parent: UINavigationController?) {
        self.parentController = parent
    }

    // MARK: - Public
    
    /// Shows modal form to create new sticker
    func newSticker() {
        // Instantiate StickerViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Sticker.initialViewController(),
              let view = nav.viewControllers.first as? StickerViewController else {
            assertionFailure("Failed to initialize StickerViewController")
            return
        }

        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = StickerPresenter(
            view: view,
            coordinator: StickerCoordinator(parent: nav),
            awardManager: AwardManager.shared,
            repository: Storage.shared.repository,
            sticker: nil,
            presentation: .modal
        )
        parentController?.present(nav, animated: true)
    }

    /// Navigates to goals / awards recap window
    func showAwardsRecap(data: [AwardRecapData]) {

        // Instantiate AwardsRecapViewController from the storyboard file
        guard let awardsView: RecapViewController = Storyboard.Recap.initialViewController() else {
            assertionFailure("Failed to initialize item details controller")
            return
        }
        
        // Hook up presenter
        awardsView.presenter = RecapPresenter(
            data: data,
            view: awardsView
        )
        parentController?.pushViewController(awardsView, animated: true)
    }

    /// Show congratulation window
    func showCongratsWindow(data: Award) {

        // Instantiate CongratsViewController from the storyboard file
        guard let congratsView: CongratsViewController = Storyboard.Congrats.initialViewController() else {
            assertionFailure("Failed to initialize CongratsViewController")
            return
        }
        
        // Hook up presenter
        congratsView.presenter = CongratsPresenter(
            data: data,
            view: congratsView,
            repository: Storage.shared.repository
        )
        congratsView.onDismiss = {
            congratsView.modalTransitionStyle = .coverVertical
            congratsView.dismiss(animated: true, completion: nil)
        }
        congratsView.modalPresentationStyle = .overFullScreen
        congratsView.modalTransitionStyle = .flipHorizontal

        // Navigate to CongratsViewController
        parentController?.present(congratsView, animated: true)
    }
    
    /// Shows onboarding window
    func showOnboardingWindow(gap: Float) {
        
        // Instantiate CongratsViewController from the storyboard file
        guard let welcomeView: WelcomeViewController = Storyboard.Onboarding2.initialViewController() else {
            assertionFailure("Failed to initialize WelcomeViewController")
            return
        }
        
        // Hook up presenter
        welcomeView.presenter = WelcomePresenter(
            view: welcomeView
        )
        welcomeView.onDismiss = {
            welcomeView.dismiss(animated: true, completion: nil)
        }
        welcomeView.modalPresentationStyle = .overFullScreen
        welcomeView.modalTransitionStyle = .crossDissolve
        welcomeView.gap = gap

        // Navigate to WelcomeViewController
        parentController?.present(welcomeView, animated: true)
    }

    /// Navigates to specific goal
    func showGoal(_ goal: Goal) {

        // Instantiate GoalViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Goal.initialViewController(),
              let view = nav.viewControllers.first as? GoalViewController else {
            assertionFailure("Failed to initialize GoalViewController")
            return
        }

        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = GoalPresenter(
            view: view,
            coordinator: GoalCoordinator(parent: parentController),
            awardManager: AwardManager.shared,
            repository: Storage.shared.repository,
            goal: goal,
            presentation: .push,
            editing: false
        )
        parentController?.pushViewController(view, animated: true)
    }
}
