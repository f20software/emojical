//
//  DataSource+Stamp.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//
import Foundation
import GRDB

// MARK: - Stamps Helper Methods
extension DataSource {

    // Single stamp object
    func stampById(_ identifier: Int64?) -> Stamp? {
        guard let id = identifier else { return nil }
        return storedStamp(withId: id)?.toModel()
    }
    
    // Count for specific stamp in Diary table
    func stampCountById(_ identifier: Int64) -> Int {
        do {
            return try dbQueue.read { db -> Int in
                let request = StoredDiary.filter(StoredDiary.Columns.stampId == identifier)
                return try request.fetchCount(db)
            }
        }
        catch { }
        return 0
    }

    // Last used stamp date from Diary
    func stampLastUsed(_ identifier: Int64) -> String? {
        do {
            return try dbQueue.read { db -> String? in
                let request = StoredDiary
                    .filter(StoredDiary.Columns.stampId == identifier)
                    .order(StoredDiary.Columns.date.desc)
                return try request.fetchOne(db)?.date
            }
        }
        catch { }
        return nil
    }

    // Only favorites stamps - used in day view
    func favoriteStamps() -> [Stamp] {
        do {
            return try dbQueue.read { db -> [StoredStamp] in
                let request = StoredStamp
                    .filter(StoredStamp.Columns.favorite == true && StoredStamp.Columns.deleted == false)
                    .order(StoredStamp.Columns.name)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }

    // All stamps
    func allStamps(includeDeleted: Bool = false) -> [Stamp] {
        allStoredStamps(includeDeleted: includeDeleted).map { $0.toModel() }
    }
    
    // Delete all stamps from the database
    func deleteAllStamps() {
        do {
            _ = try dbQueue.write { db in
                try StoredStamp.deleteAll(db)
            }
        }
        catch { }
    }

    // Stamp Ids for a day (will be stored in Diary table)
    func stampsIdsForDay(_ day: Date) -> [Int64] {
        do {
            return try dbQueue.read { db in
                let request = StoredDiary
                    .filter(StoredDiary.Columns.date == day.databaseKey)
                    // .order(StoredDiary.Columns.)
                let allrecs = try request.fetchAll(db)
                return allrecs.map({ $0.stampId })
            }
        }
        catch { }
        return []
    }

    // Stamp names for a day
    func stampsNamesForDay(_ day: Date) -> [String] {
        let ids = stampsIdsForDay(day)
        var result = [String]()
        
        for id in ids {
            if let name = stampById(id)?.name {
                result.append(name)
            }
        }
        
        return result
    }

    // Recalculate count and lastUsed in Stamp object
    func updateStatsForStamps(_ stampIds: [Int64]) {
        for id in stampIds {
            if var stamp = storedStamp(withId: id) {
                stamp.count = stampCountById(id)
                stamp.lastUsed = stampLastUsed(id) ?? ""
                do {
                    try dbQueue.write { db in
                        try stamp.update(db)
                    }
                }
                catch { }
            }
        }
    }
    
    // Recalculate all Stamps
    func recalculateAllStamps() {
        let stamps = allStamps()
        updateStatsForStamps(stamps.map({ $0.id! }))
    }

    // List of goals particular stamp is used in
    func goalsUsedStamp(_ stampId: Int64) -> [Goal] {
        return self.allGoals().filter { $0.stamps.contains(stampId) }
    }
    
    // MARK: - Saving
    
    @discardableResult func save(stamp: Stamp) throws -> Stamp {
        try dbQueue.inDatabase { db in
            var stored = StoredStamp(stamp: stamp)
            try stored.save(db)
            return stored.toModel()
        }
    }
    
    // MARK: - Private helpers
    
    func storedStamp(withId id: Int64) -> StoredStamp? {
        do {
            return try dbQueue.read { db -> StoredStamp? in
                let request = StoredStamp.filter(StoredStamp.Columns.id == id)
                return try request.fetchOne(db)
            }
        }
        catch { }
        return nil
    }
    
    func allStoredStamps(includeDeleted: Bool = false) -> [StoredStamp] {
        do {
            return try dbQueue.read { db -> [StoredStamp] in
                let request = includeDeleted
                    ? StoredStamp.order(StoredStamp.Columns.name)
                    : StoredStamp
                        .filter(StoredStamp.Columns.deleted == false)
                        .order(StoredStamp.Columns.name)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }
}
