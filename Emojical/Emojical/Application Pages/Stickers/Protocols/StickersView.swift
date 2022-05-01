//
//  StickersView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

protocol StickersView: AnyObject {

    /// Return UIViewController instance (so we can present alert stuff from Presenter class)
    var viewController: UIViewController? { get }
    
    /// User tapped on the sticker
    var onStickerTapped: ((Int64) -> Void)? { get set }

    /// User tapped on the create new sticker
    var onNewStickerTapped: (() -> Void)? { get set }

    /// User tapped on Add button
    var onAddButtonTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Update page title
    func updateTitle(_ text: String)

    /// Load stats for the month
    func loadData(stickers: [StickerData])
}
