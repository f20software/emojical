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
    
    func stampById(_ identifier: Int64) -> Stamp? {
        var result: Stamp? = nil
        do {
            try dbQueue.read { db in
                let request = Stamp.filter(Stamp.Columns.id == identifier)
                result = try request.fetchOne(db)
            }
        }
        catch {
            
        }
        
        return result
    }
    
    func favoriteStamps() -> [Stamp] {
        var result = [Stamp]()
        do {
            try dbQueue.read { db in
                let request = Stamp.filter(Stamp.Columns.favorite == true).order(Stamp.Columns.id)
                result = try request.fetchAll(db)
            }
        }
        catch {
            
        }
        
        return result
    }
    
    private func keyForDate(_ date: DateYMD) -> String {
        return "\(date.year)-\(date.month)-\(date.day)"
    }
    
    func stampsForDay(_ day: DateYMD) -> [Int64] {
        var result = [Int64]()
        do {
            try dbQueue.read { db in
                let request = Diary.filter(Diary.Columns.date == keyForDate(day)).order(Stamp.Columns.id)
                let diary = try request.fetchOne(db)
                
                if diary != nil {
                    result.append(contentsOf: diary!.stamps.split(separator: ",").map{ Int64($0)! })
                }
            }
        }
        catch {
            
        }
        
        return result
    }
    
    func setStampsForDay(_ day: DateYMD, stamps: [Int64]) {
        do {
            try dbQueue.write { db in
                let ids = stamps.map { String($0) }
                var diary = Diary(date: keyForDate(day), stamps: ids.joined(separator: ","))
                try diary.insert(db)
            }
        }
        catch {
            
        }
    }
 
    func setupDatabase(_ application: UIApplication) throws {
        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        dbQueue = try AppDatabase.openDatabase(atPath: databaseURL.path)
        
        // Be a nice iOS citizen, and don't consume too much memory
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#memory-management
        dbQueue.setupMemoryManagement(in: application)
    }
}
