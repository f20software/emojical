//
//  SelectStickerData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/23/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct SelectStickerData {
    let sticker: Sticker
    let selected: Bool
}

extension SelectStickerData: Equatable, Hashable {}
