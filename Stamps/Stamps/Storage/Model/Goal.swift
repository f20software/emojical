//
//  Goal.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct Goal: Equatable, Hashable {
    
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    var name: String
    var period: Period
    var direction: Direction
    var limit: Int
    var stamps: [Int64]
    var deleted: Bool = false
    var count: Int = 0
    var lastUsed: Date?
    
    /// Default new empty goal
    static var new: Goal {
        return Goal(
            id: nil,
            name: "Do Good",
            period: .week,
            direction: .positive,
            limit: 5,
            stamps: []
        )
    }
    
    // How do we call goal limit based on direction (used in configuration screen)
    var limitName: String {
        switch direction {
        case .negative:
            return "Maximum"
        case .positive:
            return "Minimum"
        }
    }
    
    var details: String {
        var result = period.name

        if limit > 0 {
            switch direction {
            case .positive:
                result += " goal, get \(limit) or more"
            case .negative:
                result += " goal, get \(limit) or fewer"
            }
        }
        else {
            result += " goal, no limit"
        }
        
        return result
    }
    
    var statsDescription: String {
        if count <= 0 {
            return "Goal hasn't been reached yet."
        }
        
        var result = "Goal has been reached "
        if count > 1 {
            result += "\(count) times"
        }
        else {
            result += "1 time"
        }
        
        
        if let lastUsed = lastUsed {
            let df = DateFormatter()
            df.dateStyle = .medium
            result += ", last time - \(df.string(from: lastUsed))."
        }
        
        return result
    }
    
    func descriptionForCurrentProgress(_ progress: Int) -> String {
        var periodText = ""
        
        if period == .week {
            periodText = "this week"
        }
        else if period == .month {
            periodText = "this month"
        }
        
        if direction == .positive {
            if progress < limit {
                return "You've got \(progress) stickers \(periodText). \(limit - progress) to go."
            }
            else {
                return "You've reached the goal \(periodText) by getting \(progress) stickers. Great job!"
            }
        }
        else if direction == .negative {
            if progress < limit {
                return "You've got \(progress) stickers \(periodText). You still can get \(limit - progress) more."
            }
            else if progress == limit {
                return "You've got \(progress) stickers \(periodText). You will break this goal if you get one more."
            }
            else {
                return "You've broken the goal by getting \(progress) stickers \(periodText)."
            }
        }
        
        return ""
    }
}
