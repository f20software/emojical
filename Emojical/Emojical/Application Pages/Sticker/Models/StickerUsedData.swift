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
    let average: Float
    let averagePeriod: String
}

extension StickerUsedData: Equatable, Hashable {}
