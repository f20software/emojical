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
    
    // MARK: - Private

    private weak var parentController: UINavigationController?

    init(parent: UINavigationController) {
        self.parentController = parent
    }

    /// Shows modal form to create new sticker
    func newSticker() {
        guard
            let nav: UINavigationController = Storyboard.Sticker.initialViewController(),
            let stickerVC: StampViewController =
                nav.viewControllers.first as? StampViewController else {
            assertionFailure("Failed to initialize StampViewController")
            return
        }

        stickerVC.stamp = Stamp.defaultStamp
        stickerVC.presentationMode = .modal

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
