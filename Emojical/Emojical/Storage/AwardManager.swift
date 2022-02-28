//
//  AwardManager.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/2/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class AwardManager {
    
    // MARK: - Internal state

    private let repository: DataRepository
    
    // Singleton instance
    static let shared = AwardManager(repository: Storage.shared.repository)

    private init(repository: DataRepository) {
        self.repository = repository
    }

    // For weekly goals we will do the following:
    // We will store in the database last Sunday (end of week) that we recalculated
    // When app resumes we read that value and recalculate weeks for all weeks after that date until
    // we reach Sunday
    func recalculateOnAppResume() {
        recalculateTotalGoals()
        recalculateMonthlyGoals()
        if recalculateWeeklyGoals() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                NotificationCenter.default.post(name: .weekClosed, object: nil)
            })
        }
    }
    
    // When stickers are updated manually for a certain date, we will recalculate
    // all awards that could be potentially affected
    func recalculateAwards(_ date: Date) {
        recalculateAwardsForWeek(date)
        recalculateAwardsForMonth(date)
    }
    
    // Recalculate weekly goals and update last-week-update parameter in the database
    // Return 'true' if we actually "closed" one or more week and need to notify user
    private func recalculateWeeklyGoals() -> Bool {
        // Count weeks we just closed
        var closedWeeks = 0
        
        // When was the last weekly goals recalculated?
        var lastUpdated = repository.lastWeekUpdate
        if lastUpdated == nil {
            let firstEntryDate = repository.getFirstDiaryDate() ?? Date()

            // This wil be either last Sunday before first entry or last Sunday before today
            lastUpdated = firstEntryDate.lastOfWeek.byAddingWeek(-1)
        }
        
        guard var last = lastUpdated else { return false }
        while (last.databaseKey < Date().databaseKey) {
            NSLog("Last week update set \(last.databaseKey)")
            repository.lastWeekUpdate = last
            last = last.byAddingWeek(1)
            closedWeeks += 1
            recalculateAwardsForWeek(last)
        }
        
        // closedWeeks will always be at least 1, but if we actually close it one
        // we will return it here
        return (closedWeeks > 1)
    }

    // Recalculate total(overall) goals
    private func recalculateTotalGoals() {
        recalculateTotalAwardsForDate(Date())
    }

    
    // Recalculate monthly goals and update last-month-update parameter in the database
    private func recalculateMonthlyGoals() {
        // When was the last weekly goals recalculated?
        var lastUpdated = repository.lastMonthUpdate
        if lastUpdated == nil {
            let firstEntryDate = repository.getFirstDiaryDate() ?? Date()

            // This wil be last day of the previous month or last day of month
            // just before first diary entry
            lastUpdated = firstEntryDate.lastOfMonth.byAddingMonth(-1)
        }

        guard var last = lastUpdated else { return }
        while (last.databaseKey < Date().databaseKey) {
            NSLog("Last month update set \(last.databaseKey)")
            repository.lastMonthUpdate = last
            if last.databaseKey == last.lastOfMonth.databaseKey {
                last = last.byAddingDays(1).lastOfMonth
            } else {
                last = last.lastOfMonth
            }
            recalculateAwardsForMonth(last)
        }
    }

    func recalculateAwardsForMonth(_ date: Date) {
        let goals = repository.goalsBy(period: .month)
        // If we don't have goals - there is not point of recalculating anything
        guard goals.count > 0 else { return }
        
        NSLog("Recalculating monthly awards for \(date.databaseKey)")

        let end = date.lastOfMonth
        let start = date.firstOfMonth
        let past = end.databaseKey < Date().databaseKey

        // Save off array of Ids so we can easily filter existing awards by only
        // looking at ones that correspond to our goals
        let goalIds = goals.compactMap({ $0.id })
        let stampsLog = repository.diaryForDateInterval(from: start, to: end)
        var addAwards = [Award]()

        for goal in goals {
            if goal.direction == .positive {
                let (dateReached, totalCount) = positiveGoalReached(goal, diary: stampsLog)
                addAwards.append(
                    Award(with: goal,
                        date: dateReached ?? end,
                        reached: dateReached != nil,
                        count: totalCount
                    )
                )
            }
            else if (past && goal.direction == .negative) {
                let (reached, totalCount) = isNegativeGoalReached(goal, diary: stampsLog)
                addAwards.append(
                    Award(with: goal, date: end, reached: reached, count: totalCount)
                )
            }
        }
            
        // Load existing awards from the database
        let deleteAwards =
            repository.awardsInInterval(from: start, to: end).filter { (a) -> Bool in
            return goalIds.contains(a.goalId)
        }

        // Update data source with new and/or deleted awards
        if addAwards.count > 0 || deleteAwards.count > 0 {
            repository.updateAwards(add: addAwards, remove: deleteAwards)
        }
    }

    func recalculateTotalAwardsForDate(_ date: Date) {
        let goals = repository.goalsBy(period: .total)
        // If we don't have goals - there is not point of recalculating anything
        guard goals.count > 0 else { return }
        
        NSLog("Recalculating total awards for \(date.databaseKey)")

        // Save off array of Ids so we can easily filter existing awards by only
        // looking at ones that correspond to our goals
        let goalIds = goals.compactMap({ $0.id })
        var addAwards = [Award]()

        for goal in goals {
            let stampsLog = repository.diaryForStamp(ids: goal.stamps)

            if goal.direction == .positive {
                let (dateReached, totalCount) = positiveGoalReached(goal, diary: stampsLog)
                addAwards.append(
                    Award(with: goal,
                        date: dateReached ?? date,
                        reached: dateReached != nil,
                        count: totalCount
                    )
                )
            }
            else if (goal.direction == .negative) {
                let (reached, totalCount) = isNegativeGoalReached(goal, diary: stampsLog)
                addAwards.append(
                    Award(with: goal, date: date, reached: reached, count: totalCount)
                )
            }
        }
            
        // Load existing awards from the database
        let deleteAwards = repository.awardsByGoal(ids: goalIds)

        // Update data source with new and/or deleted awards
        if addAwards.count > 0 || deleteAwards.count > 0 {
            repository.updateAwards(add: addAwards, remove: deleteAwards)
        }
    }

    func recalculateAwardsForWeek(_ date: Date) {
        let goals = repository.goalsBy(period: .week)
        // If we don't have goals - there is not point of recalculating anything
        guard goals.count > 0 else { return }

        NSLog("Recalculating weekly awards for \(date.databaseKey)")

        let end = date.lastOfWeek
        let start = end.byAddingDays(-6)
        let past = end.databaseKey < Date().databaseKey

        // Save off array of Ids so we can easily filter existing awards by only looking at ones that
        // correspond to our goals
        let goalIds = goals.compactMap({ $0.id })
        let stampsLog = repository.diaryForDateInterval(from: start, to: end)
        var addAwards = [Award]()

        for goal in goals {
            if goal.direction == .positive {
                let (dateReached, totalCount) = positiveGoalReached(goal, diary: stampsLog)
                addAwards.append(
                    Award(with: goal,
                        date: dateReached ?? end,
                        reached: dateReached != nil,
                        count: totalCount
                    )
                )
            }
            else if (past && goal.direction == .negative) {
                let (reached, totalCount) = isNegativeGoalReached(goal, diary: stampsLog)
                addAwards.append(
                    Award(with: goal, date: end, reached: reached, count: totalCount)
                )
            }
        }
            
        // Load existing awards from the database
        let deleteAwards =
            repository.awardsInInterval(from: start, to: end).filter { (a) -> Bool in
            return goalIds.contains(a.goalId)
        }

        // Update data source with new and/or deleted awards
        if addAwards.count > 0 || deleteAwards.count > 0 {
            repository.updateAwards(add: addAwards, remove: deleteAwards)
        }
    }
    
    func currentProgressFor(_ goal: Goal) -> Int {
        guard (
            goal.period == .week ||
            goal.period == .month ||
            goal.period == .total) else { return 0 }

        var start, end: Date!
        if goal.period == .week {
            let today = Date()
            end = today.lastOfWeek
            start = end.byAddingDays(-6)
        }
        else if goal.period == .month {
            let today = Date()
            end = today.lastOfMonth
            start = today.firstOfMonth
        } else /* if goal.period == .total */ {
            return repository.diaryForStamp(ids: goal.stamps).count
        }
        
        let stampsLog = repository.diaryForDateInterval(from: start, to: end)
        var count = 0

        for stamp in stampsLog {
            if goal.stamps.contains(stamp.stampId) {
                count += 1
            }
        }
        
        return count
    }
    
    // Return the date goal is reached and the total count of stickers collected for this goal
    private func positiveGoalReached(_ goal: Goal, diary: [Diary]) -> (Date?, Int) {
        var count = 0
        var dateReached: Date?
        for stamp in diary {
            if goal.stamps.contains(stamp.stampId) {
                count += 1
                if count == goal.limit {
                    dateReached = stamp.date
                }
            }
        }
        
        return (dateReached, count)
    }

    // Returns true if negative goal is reached or false if it's not
    private func isNegativeGoalReached(_ goal: Goal, diary: [Diary]) -> (Bool, Int) {
        var count = 0
        var reached: Bool = true
        
        for stamp in diary {
            if goal.stamps.contains(stamp.stampId) {
                count += 1
                if count > goal.limit {
                    reached = false
                }
            }
        }
        
        return (reached, count)
    }
}
