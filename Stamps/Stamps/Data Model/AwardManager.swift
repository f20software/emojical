//
//  AwardManager.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/2/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class AwardManager {

    //
    struct AwardUpdate {
        let add: [Award]
        let delete: [Award]
    }
    
    let db: DataSource
    
    // Singleton instance
    static let shared = AwardManager(dataSource: DataSource.shared)

    private init(dataSource: DataSource) {
        self.db = dataSource
    }

    // For weekly goals we will do the following:
    // We will in the database last Sunday (end of week) that we recalculated
    // When app resumes we read that value and recalculate weeks for all weeks after that date until
    // we reach Sunday
    func recalculateOnAppResume() {
        recalculateWeeklyGoals()
        recalculateMonthlyGoals()
    }
    
    // When stickers are updated manually for a certain date, we will recalculate
    // all awards that could be potentially affected
    func recalculateAwards(_ date: Date) {
        recalculateAwardsForWeek(date)
        recalculateAwardsForMonth(date)
    }

    // Recalculate weekly goals and update last-week-update parameter in the database
    private func recalculateWeeklyGoals() {
        // When was the last weekly goals recalculated?
        var lastUpdated = DataSource.shared.lastWeekUpdate
        if lastUpdated == nil {
            var firstEntryDate = DataSource.shared.getFirstDiaryDate()
            if firstEntryDate == nil {
                firstEntryDate = Date()
            }

            // This wil be either last Sunday before first entry or last Sunday before today
            lastUpdated = CalenderHelper.shared.endOfWeek(date: firstEntryDate!).byAddingDays(-7)
        }
        
        // TODO: Date comparision! - review how it works with only date components
        while (lastUpdated! < Date()) {
            DataSource.shared.lastWeekUpdate = lastUpdated
            lastUpdated = lastUpdated!.byAddingDays(7)
            recalculateAwardsForWeek(lastUpdated!)
        }
    }
    
    // Recalculate monthly goals and update last-month-update parameter in the database
    private func recalculateMonthlyGoals() {
        // When was the last weekly goals recalculated?
        var lastUpdated = DataSource.shared.lastMonthUpdate
        if lastUpdated == nil {
            var firstEntryDate = DataSource.shared.getFirstDiaryDate()
            if firstEntryDate == nil {
                firstEntryDate = Date()
            }

            // This wil be last day of the previous month or last day of month just before first diary entry
            lastUpdated = CalenderHelper.shared.endOfMonth(date: firstEntryDate!.byAddingMonth(-1))
        }
        
        // TODO: Date comparision! - review how it works with only date components
        while (lastUpdated! < Date()) {
            DataSource.shared.lastMonthUpdate = lastUpdated
            lastUpdated = CalenderHelper.shared.endOfMonth(date: lastUpdated!.byAddingMonth(1))
            _ = recalculateAwardsForMonth(lastUpdated!)
        }
    }

    private func recalculateAwardsForMonth(_ date: Date) {
        let goals = db.goalsByPeriod(.month)
        // If we don't have goals - there is not point of recalculating anything
        guard goals.count > 0 else { return }
        
        print("Recalculating monthly awards for \(date.databaseKey)")

        let end = CalenderHelper.shared.endOfMonth(date: date)
        let start = CalenderHelper.shared.endOfMonth(date: date.byAddingMonth(-1)).byAddingDays(1)
        let past = end < Date()

        // Save off array of Ids so we can easily filter existing awards by only looking at ones that
        // correspond to our goals
        let goalIds = goals.map { $0.id! }
        let stampsLog = db.diaryForDateInterval(from: start, to: end)
        var allAwards = [Award]()

        // Only add awards if we actually had any stamps for this week
        if stampsLog.count > 0 {
            for goal in goals {
                if goal.direction == .positive, let dateReached = isPositiveGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: dateReached))
                }
                else if past && goal.direction == .negative && isNegativeGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: end.databaseKey))
                }
            }
        }
            
        // Load existing awards from the database
        let existingAwards = db.awardsForDateInterval(from: start, to: end).filter { (a) -> Bool in
            return goalIds.contains(a.goalId)
        }
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

        // Update data source and post notification about new or deleted awards
        if addAwards.count > 0 || deleteAwards.count > 0 {
            DataSource.shared.updateAwards(add: addAwards, remove: deleteAwards)
            if addAwards.count > 0 {
                NotificationCenter.default.post(name: .awardsAdded, object: addAwards)
            }
            if deleteAwards.count > 0 {
                NotificationCenter.default.post(name: .awardsDeleted, object: deleteAwards)
            }
        }
    }

    private func recalculateAwardsForWeek(_ date: Date) {
        let goals = db.goalsByPeriod(.week)
        // If we don't have goals - there is not point of recalculating anything
        guard goals.count > 0 else { return }

        print("Recalculating weekly awards for \(date.databaseKey)")

        let end = CalenderHelper.shared.endOfWeek(date: date)
        let start = end.byAddingDays(-6)
        let past = end < Date()

        // Save off array of Ids so we can easily filter existing awards by only looking at ones that
        // correspond to our goals
        let goalIds = goals.map { $0.id! }
        let stampsLog = db.diaryForDateInterval(from: start, to: end)
        var allAwards = [Award]()

        // Only add awards if we actually had any stamps for this week
        if stampsLog.count > 0 {
            for goal in goals {
                if goal.direction == .positive, let dateReached = isPositiveGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: dateReached))
                }
                else if past && goal.direction == .negative && isNegativeGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: end.databaseKey))
                }
            }
        }
            
        // Load existing awards from the database
        let existingAwards = db.awardsForDateInterval(from: start, to: end).filter { (a) -> Bool in
            return goalIds.contains(a.goalId)
        }
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

        // Update data source and post notification about new or deleted awards
        if addAwards.count > 0 || deleteAwards.count > 0 {
            DataSource.shared.updateAwards(add: addAwards, remove: deleteAwards)
            if addAwards.count > 0 {
                NotificationCenter.default.post(name: .awardsAdded, object: addAwards)
            }
            if deleteAwards.count > 0 {
                NotificationCenter.default.post(name: .awardsDeleted, object: deleteAwards)
            }
        }
    }
    
    func currentProgressFor(_ goal: Goal) -> Int {
        guard goal.period == .week || goal.period == .month else { return 0 }

        var start, end: Date?
        if goal.period == .week {
            end = CalenderHelper.shared.endOfWeek(date: Date())
            start = end!.byAddingDays(-6)
        }
        else { /* if goal.period == .month */
            let today = Date()
            end = CalenderHelper.shared.endOfMonth(date: today)
            start = CalenderHelper.shared.endOfMonth(date: today.byAddingMonth(-1)).byAddingDays(1)

        }
        
        let stampsLog = db.diaryForDateInterval(from: start!, to: end!)
        var count = 0

        for stamp in stampsLog {
            if goal.stampIds.contains(stamp.stampId) {
                count += 1
            }
        }
        
        return count
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
