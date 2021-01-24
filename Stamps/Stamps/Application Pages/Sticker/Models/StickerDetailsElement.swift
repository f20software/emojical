//
//  StickerDetailsElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum StickerDetailsElement: Hashable {
    case view(StickerViewData)
    case edit(StickerEditData)
    case deleteButton
}
