//
//  Award.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import GRDB

struct Award {
    
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    let goalId: Int64 // FK to Goals table
    let date: String // YYYY-MM-DD
}

extension Award : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension Award: Codable, FetchableRecord, MutablePersistableRecord {

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
