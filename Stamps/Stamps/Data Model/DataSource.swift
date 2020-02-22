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

    func goalById(_ identifier: Int64) -> Goal? {
        var result: Goal? = nil
        do {
            try dbQueue.read { db in
                let request = Goal.filter(Goal.Columns.id == identifier)
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
    
    func stampsForDay(_ day: Date) -> [Int64] {
        var result = [Int64]()
        do {
            try dbQueue.read { db in
                let request = Diary.filter(Diary.Columns.date == day.yyyyMmDd).order(Stamp.Columns.id)
                let allrecs = try request.fetchAll(db)
                
                for rec in allrecs {
                    result.append(rec.stampId)
                }
            }
        }
        catch {
            
        }
        
        return result
    }

    func stampsForDateInterval(from: Date, to: Date) -> [Diary] {
        var result = [Diary]()
        do {
            try dbQueue.read { db in
                let request = Diary
                    .filter(Diary.Columns.date >= from.yyyyMmDd && Diary.Columns.date <= to.yyyyMmDd)
                    .order(Diary.Columns.date)
                let allrecs = try request.fetchAll(db)

                for rec in allrecs {
                    result.append(rec)
                }
            }
        }
        catch {
            
        }
        
        return result
    }
    
    func awardsForDateInterval(from: Date, to: Date) -> [Award] {
        var result = [Award]()
        do {
            try dbQueue.read { db in
                let request = Award
                    .filter(Award.Columns.date >= from.yyyyMmDd && Award.Columns.date <= to.yyyyMmDd)
                    .order(Diary.Columns.date)
                let allrecs = try request.fetchAll(db)

                for rec in allrecs {
                    result.append(rec)
                }
            }
        }
        catch {
            
        }
        
        return result
    }

    func weeklyGoals() -> [Goal] {
        var result = [Goal]()
        do {
            try dbQueue.read { db in
                let request = Goal
                    .filter(Goal.Columns.period == Goal.Period.week)
                let allrecs = try request.fetchAll(db)

                for rec in allrecs {
                    result.append(rec)
                }
            }
        }
        catch {
            
        }
        
        return result
    }

    func setStampsForDay(_ day: Date, stamps: [Int64]) {
        do {
            try dbQueue.write { db in
                // Delete all records for that day so we can replace them with new ones
                // TODO: Potentially can optimize it by calculating the diff
                try Diary
                    .filter(Diary.Columns.date == day.yyyyMmDd)
                    .deleteAll(db)

                for stampId in stamps {
                    var diary = Diary(date: day.yyyyMmDd, count: 1, stampId: stampId)
                    try diary.insert(db)
                }
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
