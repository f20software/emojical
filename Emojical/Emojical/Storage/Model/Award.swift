//
//  Award.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct DiffAward {
    let goalId: Int64
    let date: String
    let reached: Bool
    let count: Int
    var period: Period
    var direction: Direction
    var limit: Int
    var goalName: String?
    
    init(from: Award) {
        self.goalId = from.goalId
        self.date = from.date.databaseKey
        self.reached = from.reached
        self.count = from.count
        self.period = from.period
        self.direction = from.direction
        self.limit = from.limit
        self.goalName = from.goalName
    }
}

extension DiffAward: Equatable, Hashable {}

struct Award {
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    let goalId: Int64 // FK to Goals table
    let date: Date
    let reached: Bool
    let count: Int
    // De-normalization - these values are copied from the Goal record
    var period: Period
    var direction: Direction
    var limit: Int
    var goalName: String?

    var oldStyleDescription: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        return "award_earned_on".localized(df.string(from: date))
    }
    
    var descriptionText: String {
        // Fallback to the old style
        if reached && limit == 0 {
            return oldStyleDescription
        }
        
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        let dateReached = df.string(from: date)
        
        return Language.awardDescription(
            reached: reached,
            direction: direction,
            date: dateReached,
            count: count,
            limit: limit,
            period: period
        )
    }
}

extension Award: Equatable, Hashable {}

extension Award {
    
    /// Convinience construction for the new award from a Goal instance and completion data
    init(
        with goal: Goal,
        date: Date,
        reached: Bool,
        count: Int
    ) {
        self.init(
            id: nil,
            goalId: goal.id ?? 0,
            date: date,
            reached: reached,
            count: count,
            period: goal.period,
            direction: goal.direction,
            limit: goal.limit,
            goalName: goal.name
        )
    }
}
