//
//  Award.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB
import UIKit

struct StoredAward {
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    let goalId: Int64 // FK to Goals table
    let date: String // YYYY-MM-DD

    let reached: Bool
    let count: Int
    // De-normalization - these values are copied from the Goal record
    let period: Period
    let direction: Direction
    let limit: Int
    let goalName: String?
    // De-normalization - these values are copied from the Sticker record
    let label: String?
    let backgroundColor: String?
}

extension StoredAward : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension StoredAward: Codable, FetchableRecord, MutablePersistableRecord {

    static var databaseTableName = "award"
    
    // Define database columns
    enum Columns: String, ColumnExpression {
        case id
        case goalId
        case date
        case reached
        case count
        case period
        case direction
        case limit
        case goalName
        case label
        case backgroundColor
    }

    // Update an award id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Database access

// Define some useful player requests.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
extension StoredAward {
    static func orderedByDateDesc() -> QueryInterfaceRequest<StoredAward> {
        return StoredAward.order([Columns.date.desc])
    }
}

extension StoredAward {
    func toModel() -> Award {
        Award(
            id: id,
            goalId: goalId,
            date: Date(yyyyMmDd: date),
            reached: reached,
            count: count,
            period: period,
            direction: direction,
            limit: limit,
            goalName: goalName,
            label: label,
            backgroundColor: backgroundColor != nil ?
                UIColor(hex: backgroundColor!) : Theme.main.colors.tint
        )
    }
    
    init(award: Award) {
        self.id = award.id
        self.goalId = award.goalId
        self.date = award.date.databaseKey
        self.reached = award.reached
        self.count = award.count
        self.period = award.period
        self.direction = award.direction
        self.limit = award.limit
        self.goalName = award.goalName
        self.label = award.label
        self.backgroundColor = award.backgroundColor?.hex
    }
}
