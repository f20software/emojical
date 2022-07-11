//
//  StickersCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

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

    /// Push to edit sticker form
    func editSticker(_ sticker: Sticker) {
        navigateToSticker(mode: .push, sticker: sticker)
    }

    /// Shows modal form to create new sticker
    func newSticker() {
        navigateToSticker(mode: .modal, sticker: nil)
    }


    // MARK: - Private helpers
    
    // Navigate to Sticker edit / create screen - if `goal` object is passed will
    // push StickerViewController, otherwise - present as modal
    private func navigateToSticker(mode: PresentationMode, sticker: Sticker?) {

        // Instantiate StickerViewController from the storyboard file
        guard let nav: UINavigationController = Storyboard.Sticker.initialViewController(),
              let view = nav.viewControllers.first as? StickerViewController else {
            assertionFailure("Failed to initialize StickerViewController")
            return
        }

        let coordinator = StickerCoordinator(parent: mode == .modal ? nav : parentController)
        
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
