//
//  SelectStickersView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/23/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol SelectStickersView: AnyObject {

    // MARK: - Callbacks
    
    /// User tapped on sticker (select / deselect)
    var onStickerTapped: ((Int64) -> Void)? { get set }

    /// User tapped on create new sticker
    var onNewStickerTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Loads stickers data
    func loadData(_ data: [SelectStickerElement])
}
