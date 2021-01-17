//
//  Award.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct Award {
    // Default award badge color - should not really happen ever
    static let defaultColor = UIColor.red

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
        return "Earned on \(df.string(from: date))"
    }
    
    var descriptionText: String {
        // Fallback to the old style
        if reached && limit == 0 {
            return oldStyleDescription
        }
        
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        switch direction {
        case .positive:
            if reached {
                return "Earned on \(df.string(from: date)), by getting \(count) stickers."
            } else {
                return "\(period.name) goal not reached. Got \(count) stickers (needed \(limit))."
            }

        case .negative:
            if reached {
                return "Earned on \(df.string(from: date)). You had \(count) stickers (limit was \(limit))."
            } else {
                return "\(period.name) goal not reached. Got \(count) stickers (limit was \(limit))."
            }
        }
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
