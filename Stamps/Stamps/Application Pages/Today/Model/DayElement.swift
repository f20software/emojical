//
//  DayElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum DayElement: Hashable {
    case header(DayHeaderData)
    case stamp(StickerData)
}
