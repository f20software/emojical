//
//  StampSelectorElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/11/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum StampSelectorElement: Hashable {
    case stamp(StickerData)
    case newStamp
}
