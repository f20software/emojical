//
//  DataSource+ImportExport.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

//
// Import/Export is not publicly available feature yet. I'm using it to
// move data from my personal phone that I'm using for beta-testing
// into clean simulators, so I can test various things locally.
//
// Export is available from the Options page on the app. Json file will be generated
// and attached to compose mail ready for emailing.
//
// Save off backup.json file into /Users/sha/Desktop folder and uncomment call
// for importDatabase() method
//

extension DataSource {

    // Combining all database objects into single structure for easy json decode/encode
    struct DatabaseDump: Codable {
        var stamps: [Stamp]
        var goals: [Goal]
        var awards: [Award]
        var diary: [Diary]
    }

    // Remove everything from the database
    func clearDatabase() {
        deleteAllStamps()
        deleteAllGoals()
        deleteAllAwards()
        deleteAllDiary()
    }
    
    // Recreate database from the DatabaseDump structure
    func recreateDatabase(data: DatabaseDump) {
        for item in data.stamps {
            try! dbQueue.inDatabase { db in
                var stamp = item
                try stamp.save(db)
            }
        }
        for item in data.goals {
            try! dbQueue.inDatabase { db in
                var goal = item
                try goal.save(db)
            }
        }
        for item in data.diary {
            try! dbQueue.inDatabase { db in
                var diary = item
                try diary.save(db)
            }
        }
        for item in data.awards {
            try! dbQueue.inDatabase { db in
                var award = item
                try award.save(db)
            }
        }
    }
    
    static let backupFile = "backup.json"
    var deviceBackupFileName: URL {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: "\(documents)/\(DataSource.backupFile)")
    }
    
    var localBackupFileName: URL {
        return URL(fileURLWithPath: "/Users/sha/Desktop/\(DataSource.backupFile)")
    }

    // Backup whole database into URL
    func backupDatabase(to file: URL) -> Bool {
        let dump = DatabaseDump(stamps: allStamps(includeDeleted: true),
            goals: allGoals(includeDeleted: true),
            awards: allAwards(),
            diary: allDiary())
        var result = true
        
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(dump)
            try String(data: json, encoding: .utf8)?.write(to: file, atomically: true, encoding: .utf8)
        }
        catch {
            print("Failed to backup database")
            result = false
        }
        
        return result
    }
    
    // Read and import database from file
    func importDatabase(from file: URL) {
        let decoder = JSONDecoder()
        var dump: DatabaseDump?
        
        do {
            dump = try decoder.decode(DatabaseDump.self, from: Data(contentsOf: file, options: .alwaysMapped))
        }
        catch {
            print("Failed to read database. Import will not proceed.")
        }
        
        guard dump != nil else { return }
        
        clearDatabase()
        recreateDatabase(data: dump!)
    }
}
