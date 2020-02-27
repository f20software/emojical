//
//  Stamp.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

struct Stamp {
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    var name: String
    var label: String
    var color: String // Hex represenatation like 01cd12
    var favorite: Bool
    var deleted: Bool
    
    // Right now these two fields are auto-calculatable - we will load them when necessary
    // Later we might decide to add them to persistent storage 
    var useCount: Int?
    var lastUsedDate: String?
    
    var statsDescription: String {
        if useCount ?? 0 == 0 {
            return "Stamp hasn't been used yet."
        }
        
        var result = "Stamp has been used "
        if useCount! > 1 {
            result += "\(useCount!) times"
        }
        else {
            result += "1 time"
        }
        
        
        if let dateStr = lastUsedDate {
            let date = Date(yyyyMmDd: dateStr)
            let df = DateFormatter()
            df.dateStyle = .medium
            result += ", last time - \(df.string(from: date))"
        }
        
        return result
    }
}

extension Stamp : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension Stamp: Codable, FetchableRecord, MutablePersistableRecord {

    // Define database columns
    enum Columns: String, ColumnExpression {
        case id
        case name
        case label
        case color
        case favorite
        case deleted
    }

    // Update a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Database access

// Define some useful player requests.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
extension Stamp {
    static func orderedByName() -> QueryInterfaceRequest<Stamp> {
        return Stamp.order(Columns.name)
    }
}
