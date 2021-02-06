//
//  GoalViewData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct GoalReachedData {
    // Text information to be displayed on the Goal details in view mode
    let count: Int
    let lastUsed: Date?
    let streak: Int
    let history: [GoalHistoryPoint]
}

struct GoalHistoryPoint {
    let weekStart: Date
    let total: Int
    let limit: Int
    let reached: Bool
}

extension GoalHistoryPoint: Equatable, Hashable {}
extension GoalReachedData: Equatable, Hashable {}
