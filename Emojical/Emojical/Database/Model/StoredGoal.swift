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
    
    func toModel(repository: DataRepository) -> Goal {
        let stickers = repository.stickersBy(ids:
            stamps.split(separator: ",").map{ Int64($0)! })
        
        return Goal(
            id: id,
            name: name,
            period: period,
            direction: direction,
            limit: limit,
            stickers: stickers,
            deleted: deleted,
            count: count,
            lastUsed: lastUsed.count > 0 ? Date(yyyyMmDd: lastUsed) : nil
        )
    }
    
    init(goal: Goal) {
        self.id = goal.id
        self.name = goal.name
        self.period = goal.period
        self.direction = goal.direction
        self.limit = goal.limit
        self.stamps = goal.stickersIds.map({ "\($0)" }).joined(separator: ",")
        self.deleted = goal.deleted
        self.count = goal.count
        self.lastUsed = goal.lastUsed?.databaseKey ?? ""
    }
}
