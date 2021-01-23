//
//  SelectStickerData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/23/2021.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct SelectStickerData {
    let sticker: Stamp
    let selected: Bool
}

extension SelectStickerData: Equatable, Hashable {}
