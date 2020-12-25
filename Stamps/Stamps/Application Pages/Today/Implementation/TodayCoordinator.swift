//
//  TodayPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class TodayCoordinator: TodayCoordinatorProtocol {
    
    // MARK: - Private

    private weak var parentController: UINavigationController?

    init(parent: UINavigationController) {
        self.parentController = parent
    }

    /// Shows modal form to create new sticker
    func newSticker() {
        guard
            let navVC: UINavigationController =
                Storyboard.Stickers.viewController(withIdentifier: "newSticker"),
            let stickerVC: StampViewController =
                navVC.viewControllers.first as? StampViewController else {
            assertionFailure("Failed to initialize item details controller")
            return
        }

        stickerVC.stamp = Stamp.defaultStamp
        stickerVC.presentationMode = .modal

        parentController?.present(navVC, animated: true, completion: nil)
    }

    /// Navigates to goals / awards recap window
    func showAwardsRecap(data: [AwardRecapData]) {
        guard let awardsView: AwardsRecapView = Storyboard.Recap.initialViewController() else {
            assertionFailure("Failed to initialize item details controller")
            return
        }
        
        let presenter = RecapPresenter(
            data: data,
            view: awardsView
        )
        awardsView.presenter = presenter

        parentController?.pushViewController(awardsView, animated: true)
    }
}
