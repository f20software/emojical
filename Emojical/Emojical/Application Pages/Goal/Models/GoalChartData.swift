//
//  GoalChartData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/16/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Data model required to draw a goal / award chart for the last X periods
struct GoalChartData {
    let header: String
    let points: [GoalChartPoint]
}

/// Single chart point information
struct GoalChartPoint {
    let weekStart: Date
    let total: Int
    let limit: Int
    let reached: Bool
    
    /// Convinience constructor for the data point when both Award and Goal objects are found
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
    }

    /// Convience constructor for the case when we didn't find Award object and creating date point
    /// for the goal that was not reached
    init(weekStart: Date, goal: Goal) {
        self.weekStart = weekStart
        self.reached = false
        self.limit = goal.limit
        // This is somewhat fake, but acceptable
        switch goal.direction {
        case .positive:
            self.total = goal.limit - 1
        case .negative:
            self.total = goal.limit + 1
        }
    }
    
}

extension GoalChartPoint: Equatable, Hashable {}
extension GoalChartData: Equatable, Hashable {}
