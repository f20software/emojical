//
//  DataSource+Award.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//
import Foundation
import GRDB

// MARK: - Award Helper Methods
extension DataSource {

    // Awards for date interval
    func awardsForDateInterval(from: Date, to: Date) -> [Award] {
        do {
            return try dbQueue.read { db -> [Award] in
                let request = Award
                    .filter(Award.Columns.date >= from.databaseKey && Award.Columns.date <= to.databaseKey)
                    .order(Diary.Columns.date)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }
}
