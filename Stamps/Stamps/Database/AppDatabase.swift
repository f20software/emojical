//
//  AppDatabase.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/24/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import GRDB

// A type responsible for initializing the application database.
//
// See AppDelegate.setupDatabase()

struct AppDatabase {
    
    // Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        // Connect to the database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
        let dbQueue = try DatabaseQueue(path: path)
        
        // Define the database schema
        try migrator.migrate(dbQueue)
        
        return dbQueue
    }
    
    // The DatabaseMigrator that defines the database schema.
    //
    // See https://github.com/groue/GRDB.swift/blob/master/README.md#migrations
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("db-v0") { db in
            // Create a table for stamps
            try db.create(table: "stamp") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).collate(.localizedCaseInsensitiveCompare)
                t.column("label", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("color", .text).notNull().collate(.nocase)
                t.column("favorite", .boolean).notNull()
                t.column("deleted", .boolean).notNull()
                t.column("count", .integer).notNull().defaults(to: 0)
                t.column("lastUsed", .text).notNull().defaults(to: "")
            }

            // Create a table for diary
            try db.create(table: "diary") { t in
                t.column("date", .text).notNull().collate(.nocase) // YYYY-MM-DD format
                t.column("count", .integer).notNull()
                t.column("stampId", .integer).notNull() 
            }

            // Create a table for goals
            try db.create(table: "goal") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).collate(.localizedCaseInsensitiveCompare)
                t.column("period", .integer).notNull()
                t.column("direction", .integer).notNull()
                t.column("limit", .integer).notNull()
                t.column("stamps", .text).notNull()
                t.column("deleted", .boolean).notNull()
                t.column("count", .integer).notNull().defaults(to: 0)
                t.column("lastUsed", .text).notNull().defaults(to: "")
            }

            // Create a table for awards
            try db.create(table: "award") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("goalId", .integer).notNull()
                t.column("date", .text).notNull()
            }

            try db.create(table: "param") { t in
                t.column("name", .text).notNull()
                t.column("value", .text).notNull()
            }
        }
        
        migrator.registerMigration("db-state-1") { db in
            // Create a table for various app params
        }

//        "B8B09B", "Gold",
//        "7B92A3", "Grey",
//        "6AB1D8", "Sky Blue",
//        "0060A7", "Blue",
//        "00BBB3", "Green",
//        "57D3A3", "Mint",
//        "FF6A00", "Orange",
//        "BC83C9", "Purple",
//        "F6323E", "Red",
//        "ED8C6B", "Peach",
//        "FFFFFF", "White",
//        "F9BE00", "Yellow",
//
        migrator.registerMigration("db-content0") { db in
            // Fill in default stamps
            for stamp in [
                StoredStamp(id: nil, name: "Star", label: "⭐️", color: "B8B09B"),
                StoredStamp(id: nil, name: "Exercise", label: "🏐", color: "57D3A3"),
                StoredStamp(id: nil, name: "Read Book", label: "📖", color: "6AB1D8"),
                StoredStamp(id: nil, name: "Good Day", label: "🤩", color: "F9BE00"),
            ] {
                var s = stamp
                try s.insert(db)
            }

            // Fill in default stamps
            for goal in [
                StoredGoal(id: nil, name: "Excersize", period: .week, direction: .positive, limit: 3, stamps: "2")
            ] {
                var g = goal
                try g.insert(db)
            }
        }
        
        return migrator
    }
}
