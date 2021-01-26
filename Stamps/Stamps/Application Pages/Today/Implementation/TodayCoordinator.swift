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
    private var repository: DataRepository
    private var awardManager: AwardManager

    init(
        parent: UINavigationController?,
        repository: DataRepository,
        awardManager: AwardManager
    ) {
        self.parentController = parent
        self.repository = repository
        self.awardManager = awardManager
    }

    /// Shows modal form to create new sticker
    func newSticker() {
        // Instantiate StickerViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Sticker.initialViewController(),
              let view = nav.viewControllers.first as? StickerViewController else {
            assertionFailure("Failed to initialize StickerViewController")
            return
        }

        let coordinator = StickerCoordinator(
            parent: nav,
            repository: repository)
        
        // Hook up GoalPresenter and tie it together to a view controller
        view.presenter = StickerPresenter(
            view: view,
            coordinator: coordinator,
            awardManager: awardManager,
            repository: repository,
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
        let presenter = RecapPresenter(
            data: data,
            view: awardsView
        )
        awardsView.presenter = presenter

        // Navigate to AwardsRecapViewController
        parentController?.pushViewController(awardsView, animated: true)
    }
}
