//
//  StickerViewData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct StickerViewData {
    let sticker: Sticker
    let usage: String
}

extension StickerViewData: Equatable, Hashable {}
