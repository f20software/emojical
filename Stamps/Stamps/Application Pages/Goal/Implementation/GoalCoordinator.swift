//
//  StickersCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class GoalCoordinator: GoalCoordinatorProtocol {
    
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

    // Navigate to SelectSticker edit / create screen - if `sticker` object is passed will
    // push StickerViewController, otherwise - present as modal
    func selectStickers(_ selectedStickersIds: [Int64], onChange: @escaping ([Int64]) -> Void) {
        // Instantiate GoalViewController from the storyboard file
        guard let stickers = Storyboard.SelectStickers.initialViewController() as? SelectStickersViewController else {
            assertionFailure("Failed to initialize SelectStickersViewController")
            return
        }
        
        stickers.presenter = SelectStickersPresenter(
            view: stickers,
            repository: repository,
            selectedStickers: selectedStickersIds
        )
        stickers.presenter.onChange = { updatedIds in
            onChange(updatedIds)
        }

        parentController?.pushViewController(stickers, animated: true)
    }
}
