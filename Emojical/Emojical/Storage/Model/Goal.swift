//
//  Goal.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct Goal {
    
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
    
    func isReached(progress: Int) -> Bool {
        return direction == .positive && progress >= limit
    }

    /// Default new empty goal
    static var new: Goal {
        return Goal(
            id: nil,
            name: "",
            period: .week,
            direction: .positive,
            limit: 5,
            stamps: []
        )
    }
}

extension Goal: Equatable, Hashable {
    
    static func < (lhs: Goal, rhs: Goal) -> Bool {
        
        // Then compare period - weekly first
        if lhs.period != rhs.period {
            return lhs.period.rawValue < rhs.period.rawValue
        }

        // Then compare directions - positive first
        if lhs.direction != rhs.direction {
            return lhs.direction.rawValue < rhs.direction.rawValue
        }

        // Rest - use Ids to compare
        return ((lhs.id ?? 0) < (rhs.id ?? 0))
    }

}
