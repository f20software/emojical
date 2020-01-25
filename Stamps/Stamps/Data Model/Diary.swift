//
//  Stamp.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import GRDB

struct Diary {
    let date: String // YYYY-MM-DD format
    let stamps: String // id1,id2...
}

extension Diary : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension Diary: Codable, FetchableRecord, MutablePersistableRecord {

    // Define database columns
    enum Columns: String, ColumnExpression {
        case date
        case stamps
    }

    // Update a player id after it has been inserted in the database.
//    mutating func didInsert(with rowID: Int64, for column: String?) {
//        id = rowID
//    }
}
