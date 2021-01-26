//
//  SelectStickerElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/25/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Unified view model for select sticker collection view
enum SelectStickerElement: Hashable {
    case sticker(SelectStickerData)
    case newSticker
}
