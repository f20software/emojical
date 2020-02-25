//
//  Goal.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import GRDB

struct Goal {
    
    enum Period: Int, DatabaseValueConvertible, Decodable, Encodable {
        case week
        case month
        case year // not used
        case total // not used
    }

    enum Direction: Int, DatabaseValueConvertible, Decodable, Encodable {
        case positive
        case negative
    }

    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    var name: String
    var period: Period
    var direction: Direction
    var limit: Int
    var stamps: String // Ids of Stamps that should be checked for this goal
    var deleted: Bool
    
    // Convinience property to get and set stamp Ids by array of Ints
    var stampIds: [Int64] {
        get {
            return stamps.split(separator: ",").map{ Int64($0)! }
        }
        set {
            stamps = newValue.map({ String($0) }).joined(separator: ",")
        }
    }
    
    // How do we call goal limit based on direction (used in configuration screen)
    var limitName: String {
        switch direction {
        case .negative:
            return "Maximum"
        case .positive:
            return "Minimum"
        }
    }
    
    var details: String {
        var result = ""
        switch period {
        case .week:
            result += "Weekly"
        case .month:
            result += "Monthly"
        case .year:
            result += "Annumal"
        case .total:
            result += "Overall"
        }

        if limit > 0 {
            switch direction {
            case .positive:
                result += ", \(limit) or more"
            case .negative:
                result += ", \(limit) or fewer"
            }
        }
        else {
            result += ", no limit"
        }
        
        return result
    }
}

extension Goal : Hashable { }
    
// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension Goal: Codable, FetchableRecord, MutablePersistableRecord {

    // Define database columns
    enum Columns: String, ColumnExpression {
        case id
        case name
        case period
        case direction
        case limit
        case stamps
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
extension Goal {
    static func orderedByName() -> QueryInterfaceRequest<Goal> {
        return Goal.order(Columns.name)
    }
}
