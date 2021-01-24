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

    // Navigate to SelectStickers screen
//    func selectStickers(_ selectedStickersIds: [Int64], onChange: @escaping ([Int64]) -> Void) {
//
//        guard let stickers = Storyboard.SelectStickers.initialViewController() as? SelectStickersViewController else {
//            assertionFailure("Failed to initialize SelectStickersViewController")
//            return
//        }
//        
//        stickers.presenter = SelectStickersPresenter(
//            view: stickers,
//            repository: repository,
//            selectedStickers: selectedStickersIds
//        )
//        // Whenever selected stickers changed, notify caller via callback
//        stickers.presenter.onChange = { updatedIds in
//            onChange(updatedIds)
//        }
//
//        parentController?.pushViewController(stickers, animated: true)
//    }
}
