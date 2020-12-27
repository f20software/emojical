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

    var descriptionText: String {
        let df = DateFormatter()
        df.dateStyle = .long
        
        if reached {
            // Old style data - don't have details about limit and count - just the date
            if limit == 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                let reachedDate = formatter.string(from: date)
                return "Goal reached on \(reachedDate)"
            } else {
            // New style data - have all details
                if direction == .positive {
                    return "Got \(count) stickers (needed \(limit)). Earned on \(df.string(from: date))."
                } else {
                    return "Got \(count) stickers (needed \(limit)). Earned on \(df.string(from: date))."
                }
            }
        } else {
            // New style data - have all details
            switch direction {
            case .positive:
                return "Not reached. Got \(count) stickers (needed \(limit))."

            case .negative:
                return "Busted. Got \(count) stickers (limit was \(limit))."
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
