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
    let direction: Direction
    
    init(weekStart: Date, award: Award, goal: Goal) {
        self.weekStart = weekStart
        // Old data - no limit/total stored in the award object? Take it from the goal then
        if award.limit == 0 {
            switch goal.direction {
            case .positive:
                self.total = award.reached ? goal.limit : goal.limit - 1
            case .negative:
                self.total = award.reached ? goal.limit : goal.limit + 1
            }
            self.limit = goal.limit
        } else {
            self.total = award.count
            self.limit = award.limit
        }
        self.reached = award.reached
        self.direction = goal.direction
    }
    
    init(weekStart: Date, goal: Goal) {
        self.weekStart = weekStart
        self.reached = false
        self.limit = goal.limit
        self.direction = goal.direction
        switch goal.direction {
        case .positive:
            self.total = goal.limit - 1
        case .negative:
            self.total = goal.limit + 1
        }
    }
    
}

extension GoalHistoryPoint: Equatable, Hashable {}
extension GoalReachedData: Equatable, Hashable {}
