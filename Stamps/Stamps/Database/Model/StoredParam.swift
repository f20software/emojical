//
//  Param.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import GRDB

struct StoredParam {
    let name: String
    let value: String
}

extension StoredParam : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension StoredParam: Codable, FetchableRecord, MutablePersistableRecord {

    static var databaseTableName = "param"
    
    // Define database columns
    enum Columns: String, ColumnExpression {
        case name
        case value
    }
}
