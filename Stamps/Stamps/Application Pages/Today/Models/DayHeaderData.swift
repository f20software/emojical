//
//  DayHeaderData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct DayHeaderData {
    let date: Date
    let dayNum: String
    let dayName: String
    let isToday: Bool
    let isWeekend: Bool
    let isHighlighted: Bool
}

extension DayHeaderData: Equatable, Hashable {}
