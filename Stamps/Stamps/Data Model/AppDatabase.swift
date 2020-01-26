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
            // See https://github.com/groue/GRDB.swift#create-tables
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
        }
        
        migrator.registerMigration("db-content0") { db in
            // Fill in default stamps
            for stamp in [
                Stamp(id: nil, name: "Exercise", label: "run", color: "8cba51", favorite: true, deleted: false),
                Stamp(id: nil, name: "Drink", label: "wineglass", color: "0f4c75", favorite: true, deleted: false),
                Stamp(id: nil, name: "Red meat", label: "steak", color: "c9485b", favorite: true, deleted: false),
                Stamp(id: nil, name: "Sweets", label: "cupcake", color: "4d4646", favorite: true, deleted: false),
                Stamp(id: nil, name: "Not feeling good", label: "frown", color: "3282b8", favorite: true, deleted: false)
            ] {
                var s = stamp
                try s.insert(db)
            }
        }
        
        return migrator
    }
}
