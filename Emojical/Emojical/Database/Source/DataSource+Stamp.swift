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

    /// Stamp by a given Id
    func stampBy(id: Int64?) -> Stamp? {
        guard let id = id else { return nil }
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

    /// Stamp Ids for a day from Diary table
    func stampsIdsFor(day: Date) -> [Int64] {
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

    /// Stamps for a day
    func stampsFor(day: Date) -> [Stamp] {
        return stampsIdsFor(day: day)
            .compactMap({ stampBy(id: $0) })
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

    /// List of goals particular stamp is used in
    func goalsUsedStamp(_ stampId: Int64?) -> [Goal] {
        guard let id = stampId else { return [] }
        return self.allGoals().filter { $0.stamps.contains(id) }
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
                    ? StoredStamp.all()
                    : StoredStamp.filter(StoredStamp.Columns.deleted == false)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }
}
