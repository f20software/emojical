//
//  DataSource+Award.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//
import Foundation
import UIKit
import GRDB

// MARK: - Award Helper Methods
extension DataSource {

    // All awards
    func allAwards() -> [Award] {
        allStoredAwards().map { $0.toModel() }
    }

    // Delete all awards from the database
    func deleteAllAwards() {
        do {
            _ = try dbQueue.write { db in
                try StoredAward.deleteAll(db)
            }
        }
        catch { }
    }

    // Recent awards
    func recentAwards() -> [Award] {
        do {
            return try dbQueue.read { db -> [StoredAward] in
                let request = StoredAward.order(StoredAward.Columns.date.desc).limit(10)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }
    
    func awardsGroupedByMonth(_ awards: [Award]) -> [[Award]] {
        var result = [[Award]]()
        var month = [Award]()
        
        for i in 0..<awards.count {
            if month.count == 0 {
                month.append(awards[i])
            }
            else if month[0].date.monthKey == awards[i].date.monthKey {
                month.append(awards[i])
            }
            else {
                result.append(month)
                month = [Award]()
                month.append(awards[i])
            }
        }
        
        result.append(month)
        return result
    }

    // Awards for date interval
    func awardsForDateInterval(from: Date, to: Date) -> [Award] {
        do {
            return try dbQueue.read { db -> [StoredAward] in
                let request = StoredAward
                    .filter(StoredAward.Columns.date >= from.databaseKey && StoredAward.Columns.date <= to.databaseKey)
                    .order(StoredDiary.Columns.date)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
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
                    var stored = StoredAward(id: $0.id, goalId: $0.goalId, date: $0.date.databaseKey)
                    try stored.save(db)
                })
                
                let idsToDelete = remove.compactMap { $0.id }
                try StoredAward
                    .filter(idsToDelete.contains(StoredAward.Columns.id))
                    .deleteAll(db)
            }
        }
        catch { }

        if add.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                NotificationCenter.default.post(name: .awardsAdded, object: add)
                print("Awards added: \(add.count)")
            })
        }
        if remove.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                NotificationCenter.default.post(name: .awardsDeleted, object: remove)
                print("Awards removed: \(add.count)")
            })
        }
        updateStatsForGoals(ids)
    }
    
    // Retrieve list of monthly awards given for the month of input date
    func monthlyAwardsForMonth(date: Date) -> [Award] {
        let endOfMonth = CalenderHelper.shared.endOfMonth(date: date)
        let startOfMonth = CalenderHelper.shared.endOfMonth(date: endOfMonth.byAddingMonth(-1)).byAddingDays(1)
        
        // Load monthly goals so we can filter awards by their Ids
        let monthlyGoalIds = goalsByPeriod(.month).map({ $0.id! })
        let awards = awardsForDateInterval(from: startOfMonth, to: endOfMonth)
            .filter({ monthlyGoalIds .contains( $0.goalId )})

        return awards
    }

    // Retrieve list of weekly awards given for the month of input date
    func weeklyAwardsForMonth(date: Date) -> [Award] {
        let endOfMonth = CalenderHelper.shared.endOfMonth(date: date)
        let startOfMonth = CalenderHelper.shared.endOfMonth(date: endOfMonth.byAddingMonth(-1)).byAddingDays(1)
        
        // Load monthly goals so we can filter awards by their Ids
        let weeklyGoalIds = goalsByPeriod(.week).map({ $0.id! })
        let awards = awardsForDateInterval(from: startOfMonth, to: endOfMonth)
            .filter({ weeklyGoalIds.contains( $0.goalId )})

        return awards
    }

    // Retrieve list of monthly awards given for given week.
    func monthlyAwardsForInterval(start: Date, end: Date) -> [Award] {
        // Load monthly goals so we can filter awards by their Ids
        let monthlyGoalIds = goalsByPeriod(.month).map({ $0.id! })
        let awards = awardsForDateInterval(from: start, to: end)
            .filter({ monthlyGoalIds.contains( $0.goalId )})
        return awards
    }
    
    // Retrieve list of weekly awards given for the week with specific end date
    func weeklyAwardsForInterval(start: Date, end: Date) -> [Award] {
        // Load weekly goals so we can filter awards by their Ids
        let weeklyGoalIds = goalsByPeriod(.week).map({ $0.id! })
        let awards = awardsForDateInterval(from: start, to: end)
            .filter({ weeklyGoalIds.contains( $0.goalId )})
        return awards
    }
    
    // Get color for an award. Currently we just check the goal this award was given for
    // and get color of the first stamp on that goal
    func colorForAward(_ award: Award) -> UIColor {
        if let goal = goalById(award.goalId),
            let stampId = goal.stamps.first,
            let stamp = stampById(stampId) {
            return stamp.color
        }
        
        return Award.defaultColor
    }
    
    // MARK: - Private helpers
    
    func storedAward(withId id: Int64) -> StoredAward? {
        do {
            return try dbQueue.read { db -> StoredAward? in
                let request = StoredAward.filter(StoredAward.Columns.id == id)
                return try request.fetchOne(db)
            }
        }
        catch { }
        return nil
    }
    
    func allStoredAwards() -> [StoredAward] {
        do {
            return try dbQueue.read { db -> [StoredAward] in
                let request = StoredAward.order(StoredAward.Columns.date)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }
}
