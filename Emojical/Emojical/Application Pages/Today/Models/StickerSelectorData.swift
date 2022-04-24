//
//  StickerSelectorData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/11/2020.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct StickerSelectorData {
    /// Selecte day of the week, i.e. "Sunday"
    let selectedDay: String
    
    /// List of stickers and whether they are currently selected, optionally [+] button to create new sticker
    let stickers: [StickerSelectorElement]
}

enum StickerSelectorElement: Hashable {
    case stamp(StickerData)
    case newStamp
}
