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

    /// Goal by specified Id
    func goalBy(id: Int64?) -> Goal? {
        guard let id = id else { return nil }
        return storedGoal(withId: id)?.toModel()
    }

    // Last used stamp date from Diary
    func goalLastUsed(_ identifier: Int64) -> String? {
        do {
            return try dbQueue.read { db -> String? in
                let request = StoredAward.filter(
                    StoredAward.Columns.goalId == identifier &&
                    StoredAward.Columns.reached == true)
                .order(StoredAward.Columns.date.desc)
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

    /// Goals by period
    func goalsBy(period: Period) -> [Goal] {
        do {
            return try dbQueue.read { db -> [StoredGoal] in
                let request = StoredGoal.filter(StoredGoal.Columns.deleted == false && StoredGoal.Columns.period == period)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }
    
    /// Collect all stamp labels by iterating through Ids stored in the goal object
    func stampLabelsFor(goal: Goal) -> [String] {
        return goal.stamps.compactMap({ return stampBy(id: $0 )?.label })
    }
    
    // MARK: - Saving
    
    @discardableResult func save(goal: Goal) throws -> Goal {
        try dbQueue.inDatabase { db in
            var stored = StoredGoal(goal: goal)
            try stored.save(db)
            return stored.toModel()
        }
    }
    
    // MARK: - Private/internal helpers
    
    // Count for specific goal/award in Diary table
    private func goalCountById(_ identifier: Int64) -> Int {
        do {
            return try dbQueue.read { db -> Int in
                let request = StoredAward.filter(
                    StoredAward.Columns.goalId == identifier &&
                    StoredAward.Columns.reached == true)
                return try request.fetchCount(db)
            }
        }
        catch { }
        return 0
    }

    // Recalculate count and lastUsed in Goal object
    internal func updateStatsForGoals(_ ids: [Int64]) {
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
    
    /// Remove sticker from list of goals
    func removeSticker(_ stampId: Int64, from goalIds: [Int64]) {
        goalIds.forEach({
            var goal = goalBy(id: $0)
            if goal != nil {
                goal!.stamps.removeAll(where: { $0 == stampId })
                do {
                    try save(goal: goal!)
                }
                catch {}
            }
        })
    }
}
