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

struct Stamp {
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    var name: String
    var label: String
    var color: String // Hex representation like 01cd12
    var favorite: Bool = true
    var deleted: Bool = false
    var count: Int = 0
    var lastUsed: String = "" // YYYY-MM-DD format if stamp was used

    var statsDescription: String {
        if count <= 0 {
            return "Sticker hasn't been used yet."
        }
        
        var result = "Sticker has been used "
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
        else {
            result += "."
        }
        
        return result
    }
    
    static var defaultStamp: Stamp {
        return Stamp(id: nil, name: "Gold Star", label: "⭐️", color: UIColor.defaultStickerColor)
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
extension Stamp {
    static func orderedByName() -> QueryInterfaceRequest<Stamp> {
        return Stamp.filter(Columns.deleted == false).order(Columns.name)
    }
}
