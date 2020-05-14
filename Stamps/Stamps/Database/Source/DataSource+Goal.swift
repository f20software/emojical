//
//  DataSource+Goal.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB
import UIKit

// MARK: - Goals Helper Methods
extension DataSource {

    // Single Goal object by Id
    func goalById(_ identifier: Int64) -> Goal? {
        return storedGoal(withId: identifier)?.toModel()
    }

    // Count for specific goal/award in Diary table
    func goalCountById(_ identifier: Int64) -> Int {
        do {
            return try dbQueue.read { db -> Int in
                let request = StoredAward.filter(StoredAward.Columns.goalId == identifier)
                return try request.fetchCount(db)
            }
        }
        catch { }
        return 0
    }

    // Last used stamp date from Diary
    func goalLastUsed(_ identifier: Int64) -> String? {
        do {
            return try dbQueue.read { db -> String? in
                let request = StoredAward.filter(StoredAward.Columns.goalId == identifier).order(StoredAward.Columns.date.desc)
                return try request.fetchOne(db)?.date
            }
        }
        catch { }
        return nil
    }

    // All goals
    func allGoals(includeDeleted: Bool) -> [Goal] {
        allStoredGoals(includeDeleted: includeDeleted).map { $0.toModel() }
    }

    // Delete all goals from the database
    func deleteAllGoals() {
        do {
            _ = try dbQueue.write { db in
                try StoredGoal.deleteAll(db)
            }
        }
        catch { }
    }

    // Recalculate count and lastUsed in Goal object
    func updateStatsForGoals(_ ids: [Int64]) {
        for id in ids {
            if var goal = storedGoal(withId: id) {
                goal.count = goalCountById(id)
                goal.lastUsed = goalLastUsed(id) ?? ""
                do {
                    try dbQueue.write { db in
                        try goal.update(db)
                    }
                }
                catch { }
            }
        }
    }

    // Recalculate all Goals
    func recalculateAllGoals() {
        let goals = allGoals()
        updateStatsForGoals(goals.map({ $0.id! }))
    }

    // Goals by period
    func goalsByPeriod(_ period: Period) -> [Goal] {
        do {
            return try dbQueue.read { db -> [StoredGoal] in
                let request = StoredGoal.filter(StoredGoal.Columns.deleted == false && StoredGoal.Columns.period == period)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }
    
    // Collect all stamp labels by iterating through Ids stored in the goal object
    func stampLabelsFor(_ goal: Goal) -> [String] {
        let stampIds = goal.stamps
        var result = [String]()
        for i in stampIds {
            if let label = stampById(i)?.label {
                result.append(label)
            }
        }
        
        return result
    }
    
    // Get color for a goal. Currently we just check the goal this award was given for
    // and get color of the first stamp on that goal
    func colorForGoal(_ goalId: Int64) -> UIColor {
        if let goal = goalById(goalId),
            let stampId = goal.stamps.first,
            let stamp = stampById(stampId) {
            return stamp.color
        }
        
        return Award.defaultColor
    }

    // MARK: - Saving
    
    @discardableResult func save(goal: Goal) throws -> Goal {
        try dbQueue.inDatabase { db in
            var stored = StoredGoal(goal: goal)
            try stored.save(db)
            return stored.toModel()
        }
    }
    
    // MARK: - Private helpers
    
    func storedGoal(withId id: Int64) -> StoredGoal? {
        do {
            return try dbQueue.read { db -> StoredGoal? in
                let request = StoredGoal.filter(StoredGoal.Columns.id == id)
                return try request.fetchOne(db)
            }
        }
        catch { }
        return nil
    }
    
    func allStoredGoals(includeDeleted: Bool = false) -> [StoredGoal] {
        do {
            return try dbQueue.read { db -> [StoredGoal] in
                let request = includeDeleted
                    ? StoredGoal.order([StoredGoal.Columns.period, StoredGoal.Columns.name])
                    : StoredGoal
                        .filter(StoredGoal.Columns.deleted == false)
                        .order([StoredGoal.Columns.period, StoredGoal.Columns.name])
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }
}
