//
//  AwardManager.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/2/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class AwardManager {
    
    let db: DataSource
    
    // Singleton instance
    static let shared = AwardManager(dataSource: DataSource.shared)

    private init(dataSource: DataSource) {
        self.db = dataSource
    }
    
    func recalculateAwardsForWeek(_ date: Date) {
        let month = CalenderHelper.Month(date)
        let dayIndex = month.indexForDay(Calendar.current.component(.day, from: date))
        let weekStart = date.byAddingDays(-dayIndex)
        let weekEnd = date.byAddingDays(6-dayIndex)
        let past = weekEnd < Date()

        let stampsLog = db.diaryForDateInterval(from: weekStart, to: weekEnd)
        let weeklyGoals = db.goalsByPeriod(.week)
        var allAwards = [Award]()

        // Only add awards if we actually had any stamps for this week
        if stampsLog.count > 0 {
            for goal in weeklyGoals {
                if goal.direction == .positive, let dateReached = isPositiveGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: dateReached))
                }
                else if past && goal.direction == .negative && isNegativeGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: weekEnd.databaseKey))
                }
            }
        }
            
        // Load existing awards from the database
        let existingAwards = db.awardsForDateInterval(from: weekStart, to: weekEnd)
        // And calculate difference - separate set of awards to be added and set of awards to be deleted
        let addAwards = allAwards.filter { (a1) -> Bool in
            return existingAwards.contains { (a2) -> Bool in
                a2.goalId == a1.goalId && a2.date == a1.date
            } == false
        }
        let deleteAwards = existingAwards.filter { (a1) -> Bool in
            return allAwards.contains { (a2) -> Bool in
                a2.goalId == a1.goalId && a2.date == a1.date
            } == false
        }

        for award in addAwards {
            try! DataSource.shared.dbQueue.inDatabase { db in
                var a = award
                try a.save(db)
            }
        }
        
        for award in deleteAwards {
            _ = try! DataSource.shared.dbQueue.inDatabase { db in
                try award.delete(db)
            }
        }
    }
    
    // Return the date goal is reached or nil of goals is not reached
    func isPositiveGoalReached(_ goal: Goal, diary: [Diary]) -> String? {
        var count = 0
        for stamp in diary {
            if goal.stampIds.contains(stamp.stampId) {
                count += 1
                if count == goal.limit {
                    return stamp.date
                }
            }
        }
        
        return nil
    }

    // Returns true if negative goal is reached or false if it's not
    func isNegativeGoalReached(_ goal: Goal, diary: [Diary]) -> Bool {
        var count = 0
        for stamp in diary {
            if goal.stampIds.contains(stamp.stampId) {
                count += 1
                if count > goal.limit {
                    return false
                }
            }
        }
        
        return true
    }
}
