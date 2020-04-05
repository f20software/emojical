//
//  DataSource.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import GRDB

class DataSource {

    // Singleton instance
    static let shared = DataSource()
    
    // Database
    var dbQueue: DatabaseQueue!
    
    func setupDatabase(_ application: UIApplication) throws {
        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        dbQueue = try AppDatabase.openDatabase(atPath: databaseURL.path)
        
        // Be a nice iOS citizen, and don't consume too much memory
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#memory-management
        dbQueue.setupMemoryManagement(in: application)
    }
    
    func backupDatabase() -> URL {

        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(fileURLWithPath: documentsDirectoryPathString)
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("backup.json")
        
        let stamps = allStamps()
        let goals = allGoals()
        let awards = allAwards()
        let diary = allDiary()
        
        let jsonEncoder = JSONEncoder()
        do {
            var jsonData = try jsonEncoder.encode(stamps)
            let stampsJson = String(data: jsonData, encoding: String.Encoding.utf8)

            jsonData = try jsonEncoder.encode(goals)
            let goalsJson = String(data: jsonData, encoding: String.Encoding.utf8)
            
            jsonData = try jsonEncoder.encode(awards)
            let awardsJson = String(data: jsonData, encoding: String.Encoding.utf8)
            
            jsonData = try jsonEncoder.encode(diary)
            let diaryJson = String(data: jsonData, encoding: String.Encoding.utf8)


            try "{ \"stickers\": \(stampsJson!), \"goals\": \(goalsJson!), \"awards\": \(awardsJson!), \"diary\": \(diaryJson!) }".write(to: jsonFilePath!, atomically: true, encoding: .utf8)
        }
        catch {
            print("ops")
        }
        
        return jsonFilePath!
    }
}
