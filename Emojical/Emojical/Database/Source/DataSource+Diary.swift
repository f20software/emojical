//
//  DataSource+Diary.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//
import Foundation
import GRDB

// MARK: - Diary Helper Methods
extension DataSource {

    /// Total count of all diary records
    func allDiaryCount() -> Int {
        return allStoredDiary().count
    }
    
    func getFirstDiaryDate() -> Date? {
        do {
            let diary = try dbQueue.read { db -> StoredDiary? in
                let request = StoredDiary.order(StoredDiary.Columns.date)
                return try request.fetchOne(db)
            }
            if diary != nil {
                return Date(yyyyMmDd: diary!.date)
            }
        }
        catch { }
        return nil
    }

    /// Date of the first time sticker has been used
    func getFirstDateFor(sticker id: Int64) -> Date? {
        do {
            let diary = try dbQueue.read { db -> StoredDiary? in
                let request = StoredDiary.filter(StoredDiary.Columns.stampId == id).order(StoredDiary.Columns.date)
                return try request.fetchOne(db)
            }
            if diary != nil {
                return Date(yyyyMmDd: diary!.date)
            }
        }
        catch { }
        return nil
    }

    func getLastDiaryDate() -> Date? {
        do {
            let diary = try dbQueue.read { db -> StoredDiary? in
                let request = StoredDiary.order(StoredDiary.Columns.date.desc)
                return try request.fetchOne(db)
            }
            if diary != nil {
                return Date(yyyyMmDd: diary!.date)
            }
        }
        catch { }
        return nil
    }

    // All diary records
    func allDiary() -> [Diary] {
        allStoredDiary().map { $0.toModel() }
    }

    // Delete all diary records from the database
    func deleteAllDiary() {
        do {
            _ = try dbQueue.write { db in
                try StoredDiary.deleteAll(db)
            }
        }
        catch { }
    }

    // Diary records filtered for specific date interval
    func diaryForDateInterval(from: Date, to: Date, stampIds: [Int64]) -> [Diary] {
        do {
            return try dbQueue.read { db -> [StoredDiary] in
                let request = StoredDiary
                    .filter(
                        StoredDiary.Columns.date >= from.databaseKey &&
                        StoredDiary.Columns.date <= to.databaseKey &&
                        stampIds.contains(StoredDiary.Columns.stampId)
                    )
                    .order(StoredDiary.Columns.date)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }

    /// Diary records filtered by specific stampIds
    func diaryForStamp(ids: [Int64]) -> [Diary] {
        do {
            return try dbQueue.read { db -> [StoredDiary] in
                let request = StoredDiary
                    .filter(ids.contains(StoredDiary.Columns.stampId))
                    .order(StoredDiary.Columns.date)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }

    // Diary records filtered for specific date interval
    func diaryForDateInterval(from: Date, to: Date) -> [Diary] {
        do {
            return try dbQueue.read { db -> [StoredDiary] in
                let request = StoredDiary
                    .filter(StoredDiary.Columns.date >= from.databaseKey && StoredDiary.Columns.date <= to.databaseKey)
                    .order(StoredDiary.Columns.date)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }

    // Update array of stamps for a given day
    func setStampsForDay(_ day: Date, stamps: [Int64]) {
        // Combine list of old stamps for the day and new stamps
        // Then we will relaculate all of them
        // TODO: Can be optimized
        var allIds = diaryForDateInterval(from: day, to: day).map({ $0.stampId }) + stamps
        allIds = Array(Set(allIds))
        
        do {
            try dbQueue.write { db in
                // Delete all records for that day so we can replace them with new ones
                // TODO: Potentially can optimize it by calculating the diff
                try StoredDiary
                    .filter(StoredDiary.Columns.date == day.databaseKey)
                    .deleteAll(db)

                for stampId in stamps {
                    var diary = StoredDiary(date: day.databaseKey, count: 1, stampId: stampId)
                    try diary.insert(db)
                }
            }
        }
        catch { }
        
        updateStatsForStamps(allIds)
    }
    
    func allStoredDiary() -> [StoredDiary] {
        do {
            return try dbQueue.read { db -> [StoredDiary] in
                let request = StoredDiary.order(StoredDiary.Columns.date)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }
 }
