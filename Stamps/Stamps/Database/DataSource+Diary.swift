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

    // Diary records filtered for specific date interval
    func diaryForDateInterval(from: Date, to: Date) -> [Diary] {
        do {
            return try dbQueue.read { db -> [Diary] in
                let request = Diary
                    .filter(Diary.Columns.date >= from.databaseKey && Diary.Columns.date <= to.databaseKey)
                    .order(Diary.Columns.date)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }

    // Update array of stamps for a given day
    func setStampsForDay(_ day: Date, stamps: [Int64]) {
        do {
            try dbQueue.write { db in
                // Delete all records for that day so we can replace them with new ones
                // TODO: Potentially can optimize it by calculating the diff
                try Diary
                    .filter(Diary.Columns.date == day.databaseKey)
                    .deleteAll(db)

                for stampId in stamps {
                    var diary = Diary(date: day.databaseKey, count: 1, stampId: stampId)
                    try diary.insert(db)
                }
            }
        }
        catch { }
    }
 }
