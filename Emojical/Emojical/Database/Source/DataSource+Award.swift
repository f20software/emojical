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

    // MARK: - Observers
    
    func addAwardsObserver(_ disposable: AnyObject, onChange: @escaping () -> Void) {
        queue.async { [weak self] in
            self?.awardsOnChangeObservers.addObserver(disposable, onChange)
        }
    }

    func removeAwardsObserver(_ disposable: AnyObject) {
        queue.async { [weak self] in
            self?.awardsOnChangeObservers.removeObserver(disposable)
        }
    }

    private func notifyAwardsOnChangeObservers() {
        awardsOnChangeObservers.forEach { observer in
            observer()
        }
    }

    /// All awards
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
        notifyAwardsOnChangeObservers()
    }

    // Awards for date interval
    func awardsInInterval(from: Date, to: Date) -> [Award] {
        do {
            return try dbQueue.read { db -> [StoredAward] in
                let request = StoredAward
                    .filter(StoredAward.Columns.date >= from.databaseKey && StoredAward.Columns.date <= to.databaseKey)
                    .order(StoredAward.Columns.date)
                return try request.fetchAll(db)
            }.map { $0.toModel() }
        }
        catch { }
        return []
    }
    
    /// Awards by given Ids
    func awardsByGoal(ids: [Int64]) -> [Award] {
        do {
            return try dbQueue.read { db -> [StoredAward] in
                let request = StoredAward
                    .filter(ids.contains(StoredAward.Columns.goalId))
                    .order(StoredAward.Columns.date)
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
                    var stored = StoredAward(award: $0)
                    try stored.save(db)
                })
                
                let idsToDelete = remove.compactMap { $0.id }
                try StoredAward
                    .filter(idsToDelete.contains(StoredAward.Columns.id))
                    .deleteAll(db)
            }
        }
        catch { }

        notifyAwardsOnChangeObservers()
        updateStatsForGoals(ids)
    }

    /// Deletes awards for a given goal and given time internal
    func deleteAwards(from: Date, to: Date, goalId: Int64) {
        do {
            _ = try dbQueue.write { db in
                try StoredAward
                    .filter(StoredAward.Columns.goalId == goalId &&
                        StoredAward.Columns.date >= from.databaseKey &&
                        StoredAward.Columns.date <= to.databaseKey)
                    .deleteAll(db)
            }
        }
        catch { }
        notifyAwardsOnChangeObservers()
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
