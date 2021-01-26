//
//  Stamp.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import GRDB

struct StoredStamp {
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    var name: String
    var label: String
    var color: String // Hex representation like 01cd12
    var favorite: Bool = true
    var deleted: Bool = false
    var count: Int = 0
    var lastUsed: String = "" // YYYY-MM-DD format if stamp was used
}

extension StoredStamp : Hashable { }

// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension StoredStamp: Codable, FetchableRecord, MutablePersistableRecord {

    static var databaseTableName = "stamp"
    
    // Define database columns
    enum Columns: String, ColumnExpression {
        case id
        case name
        case label
        case color
        case favorite
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
extension StoredStamp {
    static func orderedByName() -> QueryInterfaceRequest<StoredStamp> {
        return StoredStamp.filter(Columns.deleted == false).order(Columns.name)
    }
}

// MARK: - Model conversion

extension StoredStamp {
    func toModel() -> Stamp {
        return Stamp(
            id: id,
            name: name,
            label: label,
            color: UIColor(hex: color),
            favorite: favorite,
            deleted: deleted,
            count: count,
            lastUsed: ((lastUsed.count > 0) ? Date(yyyyMmDd: lastUsed) : nil)
        )
    }
    
    init(stamp: Stamp) {
        self.id = stamp.id
        self.name = stamp.name
        self.label = stamp.label
        self.color = stamp.color.hex
        self.favorite = stamp.favorite
        self.deleted = stamp.deleted
        self.count = stamp.count
        self.lastUsed = stamp.lastUsed?.databaseKey ?? ""
    }
}
