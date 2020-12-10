//
//  StatsElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Unified view model for statistics collection view
enum StatsElement: Hashable {
    case weekHeaderCell(WeekHeaderData)
    case weekLineCell(WeekLineData)
    case monthBoxCell(MonthBoxData)
}
