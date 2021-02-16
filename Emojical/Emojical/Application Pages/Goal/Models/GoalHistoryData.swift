//
//  GoalViewData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct GoalHistoryData {
    let reached: GoalReachedData
    let chart: GoalChartData
}

struct GoalReachedData {
    // Text information to be displayed on the Goal details in view mode
    let count: Int
    let lastUsed: Date?
    let streak: Int
}

extension GoalReachedData: Equatable, Hashable {}
