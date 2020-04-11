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

struct Award {

    // Default award badge color - should not really happen ever
    static let defaultColor = UIColor.red

    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    let goalId: Int64 // FK to Goals table
    let date: String // YYYY-MM-DD
    
    var earnedOnText: String {
        let d = Date(yyyyMmDd: date)
        let df = DateFormatter()
        df.dateStyle = .long
        
        return "Earned on \(df.string(from: d))"
    }
    
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

// MARK: - Database access

// Define some useful player requests.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
extension Award {
    static func orderedByDateDesc() -> QueryInterfaceRequest<Award> {
        return Award.order([Columns.date.desc])
    }
}
