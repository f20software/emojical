//
//  Stamp.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import GRDB
import Foundation

struct StoredDiary {
    let date: String // YYYY-MM-DD format
    let count: Int
    let stampId: Int64 
}

extension StoredDiary : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension StoredDiary: Codable, FetchableRecord, MutablePersistableRecord {

    static var databaseTableName = "diary"
    
    // Define database columns
    enum Columns: String, ColumnExpression {
        case date
        case count
        case stampId
    }
}

extension StoredDiary {
    func toModel() -> Diary {
        Diary(
            date: Date(yyyyMmDd: date),
            count: count,
            stampId: stampId
        )
    }
}
