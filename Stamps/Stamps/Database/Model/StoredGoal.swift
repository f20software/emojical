//
//  Goal.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

struct StoredGoal {
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    var name: String
    var period: Period
    var direction: Direction
    var limit: Int
    var stamps: String // Ids of Stamps that should be checked for this goal
    var deleted: Bool = false
    var count: Int = 0
    var lastUsed: String = ""

    // Convinience property to get and set stamp Ids by array of Ints
    var stampIds: [Int64] {
        get {
            return stamps.split(separator: ",").map{ Int64($0)! }
        }
        set {
            stamps = newValue.map({ String($0) }).joined(separator: ",")
        }
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
    
    var periodText: String {
        switch period {
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        case .year:
            return "Annual"
        case .total:
            return "Overall"
        }
    }
    
    var details: String {
        var result = periodText

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
        
        
        if lastUsed.lengthOfBytes(using: .utf8) > 0 {
            let date = Date(yyyyMmDd: lastUsed)
            let df = DateFormatter()
            df.dateStyle = .medium
            result += ", last time - \(df.string(from: date))."
        }
        
        return result
    }
    
    //
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

extension StoredGoal : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension StoredGoal: Codable, FetchableRecord, MutablePersistableRecord {

    static var databaseTableName = "goal"
    
    // Define database columns
    enum Columns: String, ColumnExpression {
        case id
        case name
        case period
        case direction
        case limit
        case stamps
        case deleted
        case count
        case lastUsed
    }

    // Update a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Database access

// Define some useful player requests.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
extension StoredGoal {
    static func orderedByPeriodName() -> QueryInterfaceRequest<StoredGoal> {
        return StoredGoal.filter(Columns.deleted == false).order([Columns.period, Columns.name])
    }
}

// MARK: - Model conersion

extension StoredGoal {
    func toModel() -> Goal {
        Goal(
            id: id,
            name: name,
            period: period,
            direction: direction,
            limit: limit,
            stamps: stamps.split(separator: ",").map{ Int64($0)! },
            deleted: deleted,
            count: count,
            lastUsed: lastUsed.count > 0 ? Date(yyyyMmDd: lastUsed) : nil)
    }
    
    init(goal: Goal) {
        self.id = goal.id
        self.name = goal.name
        self.period = goal.period
        self.direction = goal.direction
        self.limit = goal.limit
        self.stamps = goal.stamps.map({ "\($0)" }).joined(separator: ",")
        self.deleted = goal.deleted
        self.count = goal.count
        self.lastUsed = goal.lastUsed?.databaseKey ?? ""
    }
}
