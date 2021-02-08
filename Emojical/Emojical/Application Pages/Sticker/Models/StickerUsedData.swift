//
//  StickerUsedData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/7/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct StickerUsedData {
    // Usage information to be displayed on the Sticker details in view mode
    let count: Int
    let lastUsed: Date?
    let onAverage: String // localized string in a format "on averaga|xx|per week"
}

extension StickerUsedData: Equatable, Hashable {}
