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
    
    // Helper method to add and remove some awards when goal is reached
    // Will automatically recalculate count ans lastUsed for all goals affected
    func updateAwards(add: [Award], remove: [Award]) {
        // List of goal ids that we would need to recalculate
        let ids = Array(Set(add.map({ $0.goalId }) + remove.map({ $0.goalId })))

        do {
            try dbQueue.inDatabase { db in
                try add.forEach({
                    var a = $0
                    try a.save(db)
                })
                try remove.forEach({
                    try $0.delete(db)
                })
            }
        }
        catch { }
        updateStatsForGoals(ids)
    }
}
