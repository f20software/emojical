//
//  DataSource+Upgrade.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 7/10/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

//
//

extension DataSource {

    /// Go through all awards that have no label/background information and retreive it
    func fillAwardLabels() -> Void {
        let awards = awardsWithEmptyLabels()
        var updatedAwards: [Award] = []

        awards.forEach { award in
            let goal = goalBy(id: award.goalId)
            var newAward = award
            newAward.label = goal?.stickers.first?.label
            newAward.backgroundColor = goal?.stickers.first?.color
            updatedAwards.append(newAward)
        }

        guard updatedAwards.isEmpty == false else { return }
        NSLog("Updating awards: \(updatedAwards)")
        dbQueue.inDatabase { db in
            updatedAwards.forEach { award in
                var stored = StoredAward(award: award)
                do { try stored.save(db) }
                catch { }
            }
        }
    }
}
