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
            }

            // Create a table for awards
            try db.create(table: "award") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("goalId", .integer).notNull()
                t.column("date", .text).notNull()
            }
        }
        
//        "B8B09b", "Gold",
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
                Stamp(id: nil, name: "Star", label: "star", color: "B8B09b", favorite: true),
                Stamp(id: nil, name: "Run", label: "run", color: "00BBB3", favorite: true),
                Stamp(id: nil, name: "Exercise", label: "exercise", color: "57D3A3", favorite: true),
                Stamp(id: nil, name: "Drink", label: "wineglass", color: "BC83C9", favorite: true),
                Stamp(id: nil, name: "Red meat", label: "steak", color: "BC83C9", favorite: true),
                Stamp(id: nil, name: "Sweets", label: "cupcake", color: "ED8C6B", favorite: true)
                // Stamp(id: nil, name: "Not feeling good", label: "frown", color: "3282b8", favorite: true, deleted: false)
            ] {
                var s = stamp
                try s.insert(db)
            }
        }
        
        migrator.registerMigration("db-content1") { db in
            // Fill in default stamps
            for goal in [
                Goal(id: nil, name: "Excersize", period: .week, direction: .positive, limit: 5, stamps: "2,3", deleted: false),
                Goal(id: nil, name: "Don't drink", period: .week, direction: .negative, limit: 3, stamps: "4", deleted: false)
            ] {
                var g = goal
                try g.insert(db)
            }
        }
        
        migrator.registerMigration("new-fields") { db in
            try db.alter(table: "stamp", body: { t in
                t.add(column: "count", .integer).notNull().defaults(to: 0)
                t.add(column: "lastUsed", .text).notNull().defaults(to: "")
            })
            
            try db.alter(table: "goal", body: { t in
                t.add(column: "count", .integer).notNull().defaults(to: 0)
                t.add(column: "lastUsed", .text).notNull().defaults(to: "")
            })
        }

        return migrator
    }
}
