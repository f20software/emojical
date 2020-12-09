//
//  WeekElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum WeekElement: Hashable {
    case weekHeader(WeekHeaderData)
    case weekLine(WeekLineData)
}
