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

    // Default award badge color - should not really happen ever
    static let defaultColor = UIColor.red

    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    let goalId: Int64 // FK to Goals table
    let date: String // YYYY-MM-DD
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
            date: Date(yyyyMmDd: date)
        )
    }
}
