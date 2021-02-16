//
//  GoalDetailsElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum GoalDetailsElement: Hashable {
    case view(GoalViewData)
    case reached(GoalReachedData)
    case chart(GoalChartData)
    case edit(GoalEditData)
    case deleteButton
}
