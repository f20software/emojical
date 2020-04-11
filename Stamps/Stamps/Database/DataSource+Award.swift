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
        do {
            return try dbQueue.read { db -> [Award] in
                let request = Award.order(Award.Columns.date)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }

    // Delete all awards from the database
    func deleteAllAwards() {
        do {
            _ = try dbQueue.write { db in
                try Award.deleteAll(db)
            }
        }
        catch { }
    }

    // Recent awards
    func recentAwards() -> [Award] {
        do {
            return try dbQueue.read { db -> [Award] in
                let request = Award.order(Award.Columns.date.desc).limit(10)
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }

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
            .filter({ weeklyGoalIds .contains( $0.goalId )})

        return awards
    }

    // Retrieve list of weekly awards given for the week with specific end date
    func weeklyAwardsForWeek(endingOn: Date?) -> [Award] {
        guard let date = endingOn else { return [] }
        
        // Load weekly goals so we can filter awards by their Ids
        let weeklyGoalIds = goalsByPeriod(.week).map({ $0.id! })
        let awards = awardsForDateInterval(from: date.byAddingDays(-6), to: date)
            .filter({ weeklyGoalIds.contains( $0.goalId )})
        return awards
    }
    
    // Get color for an award. Currently we just check the goal this award was given for
    // and get color of the first stamp on that goal
    func colorForAward(_ award: Award) -> UIColor {
        if let goal = goalById(award.goalId),
            let stampId = goal.stampIds.first,
            let stamp = stampById(stampId) {
            return UIColor(hex: stamp.color)
        }
        
        return Award.defaultColor
    }
}
