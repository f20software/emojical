//
//  DayHeaderData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct DayHeaderData {
    let dayNum: String
    let dayName: String
    let isCurrent: Bool
    let isWeekend: Bool
}

extension DayHeaderData: Equatable, Hashable {}
