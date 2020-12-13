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
    struct AwardUpdate {
        let add: [Award]
        let delete: [Award]
    }
    
    let repository: DataRepository
    
    // Singleton instance
    static let shared = AwardManager(repository: Storage.shared.repository)

    private init(repository: DataRepository) {
        self.repository = repository
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
    
    // Build GoalAwardData model from the Goal and Stamp object
    func goalAwardModel(for goal: Goal, stamp: Stamp?) -> GoalAwardData {
        let progress = currentProgressFor(goal)

        switch goal.direction {
        case .positive:
            if progress >= goal.limit {
                // You got it - should match award render mode
                return GoalAwardData(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: (stamp?.color ?? UIColor.appTintColor).withAlphaComponent(0.5),
                    direction: .positive,
                    progress: 1.0,
                    progressColor: UIColor.darkGray
                )
            } else {
                // Still have some work to do
                return GoalAwardData(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: UIColor.systemGray.withAlphaComponent(0.2),
                    direction: .positive,
                    progress: Float(progress) / Float(goal.limit),
                    progressColor: UIColor.positiveGoalNotReached
                )
            }
        case .negative:
            if progress > goal.limit {
                // Busted
                return GoalAwardData(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: UIColor.systemGray.withAlphaComponent(0.2),
                    direction: .negative,
                    progress: 0.0,
                    progressColor: UIColor.clear
                )
            } else {
                // Still have some room to go
                let percent: Float = Float(goal.limit - progress) / Float(goal.limit) + 0.03
                return GoalAwardData(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: (stamp?.color ?? UIColor.appTintColor).withAlphaComponent(0.3),
                    direction: .negative,
                    progress: percent,
                    progressColor: UIColor.negativeGoalNotReached
                )

            }
        }
    }

    // Build GoalAwardData model from the Award, Goal and Stamp object
    func goalAwardModel(for award: Award, goal: Goal, stamp: Stamp?) -> GoalAwardData {
        return GoalAwardData(
            goalId: goal.id,
            emoji: stamp?.label,
            backgroundColor: (stamp?.color ?? UIColor.appTintColor).withAlphaComponent(0.5),
            direction: goal.direction,
            progress: 1.0,
            progressColor: UIColor.darkGray
        )
    }

    // Recalculate weekly goals and update last-week-update parameter in the database
    private func recalculateWeeklyGoals() {
        // When was the last weekly goals recalculated?
        var lastUpdated = repository.lastWeekUpdate
        if lastUpdated == nil {
            var firstEntryDate = repository.getFirstDiaryDate()
            if firstEntryDate == nil {
                firstEntryDate = Date()
            }

            // This wil be either last Sunday before first entry or last Sunday before today
            lastUpdated = CalendarHelper.shared.endOfWeek(date: firstEntryDate!).byAddingDays(-7)
        }
        
        // TODO: Date comparision! - review how it works with only date components
        while (lastUpdated! < Date()) {
            repository.lastWeekUpdate = lastUpdated
            lastUpdated = lastUpdated!.byAddingDays(7)
            recalculateAwardsForWeek(lastUpdated!)
        }
    }
    
    // Recalculate monthly goals and update last-month-update parameter in the database
    private func recalculateMonthlyGoals() {
        // When was the last weekly goals recalculated?
        var lastUpdated = repository.lastMonthUpdate
        if lastUpdated == nil {
            var firstEntryDate = repository.getFirstDiaryDate()
            if firstEntryDate == nil {
                firstEntryDate = Date()
            }

            // This wil be last day of the previous month or last day of month just before first diary entry
            lastUpdated = CalendarHelper.shared.endOfMonth(date: firstEntryDate!.byAddingMonth(-1))
        }
        
        // TODO: Date comparision! - review how it works with only date components
        while (lastUpdated! < Date()) {
            repository.lastMonthUpdate = lastUpdated
            lastUpdated = CalendarHelper.shared.endOfMonth(date: lastUpdated!.byAddingMonth(1))
            _ = recalculateAwardsForMonth(lastUpdated!)
        }
    }

    private func recalculateAwardsForMonth(_ date: Date) {
        let goals = repository.goalsByPeriod(.month)
        // If we don't have goals - there is not point of recalculating anything
        guard goals.count > 0 else { return }
        
        print("Recalculating monthly awards for \(date.databaseKey)")

        let end = CalendarHelper.shared.endOfMonth(date: date)
        let start = CalendarHelper.shared.endOfMonth(date: date.byAddingMonth(-1)).byAddingDays(1)
        let past = end < Date()

        // Save off array of Ids so we can easily filter existing awards by only looking at ones that
        // correspond to our goals
        let goalIds = goals.map { $0.id! }
        let stampsLog = repository.diaryForDateInterval(from: start, to: end)
        var allAwards = [Award]()

        // Only add awards if we actually had any stamps for this week
        if stampsLog.count > 0 {
            for goal in goals {
                if goal.direction == .positive, let dateReached = positiveGoalReachedDate(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: dateReached))
                }
                else if past && goal.direction == .negative && isNegativeGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: end))
                }
            }
        }
            
        // Load existing awards from the database
        let existingAwards = repository.awardsForDateInterval(from: start, to: end).filter { (a) -> Bool in
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
            repository.updateAwards(add: addAwards, remove: deleteAwards)
        }
    }

    private func recalculateAwardsForWeek(_ date: Date) {
        let goals = repository.goalsByPeriod(.week)
        // If we don't have goals - there is not point of recalculating anything
        guard goals.count > 0 else { return }

        print("Recalculating weekly awards for \(date.databaseKey)")

        let end = CalendarHelper.shared.endOfWeek(date: date)
        let start = end.byAddingDays(-6)
        let past = end < Date()

        // Save off array of Ids so we can easily filter existing awards by only looking at ones that
        // correspond to our goals
        let goalIds = goals.map { $0.id! }
        let stampsLog = repository.diaryForDateInterval(from: start, to: end)
        var allAwards = [Award]()

        // Only add awards if we actually had any stamps for this week
        if stampsLog.count > 0 {
            for goal in goals {
                if goal.direction == .positive, let dateReached = positiveGoalReachedDate(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: dateReached))
                }
                else if past && goal.direction == .negative && isNegativeGoalReached(goal, diary: stampsLog) {
                    allAwards.append(Award(id: nil, goalId: goal.id!, date: end))
                }
            }
        }
            
        // Load existing awards from the database
        let existingAwards = repository.awardsForDateInterval(from: start, to: end).filter { (a) -> Bool in
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
            repository.updateAwards(add: addAwards, remove: deleteAwards)
        }
    }
    
    func currentProgressFor(_ goal: Goal) -> Int {
        guard goal.period == .week || goal.period == .month else { return 0 }

        var start, end: Date?
        if goal.period == .week {
            end = CalendarHelper.shared.endOfWeek(date: Date())
            start = end!.byAddingDays(-6)
        }
        else { /* if goal.period == .month */
            let today = Date()
            end = CalendarHelper.shared.endOfMonth(date: today)
            start = CalendarHelper.shared.endOfMonth(date: today.byAddingMonth(-1)).byAddingDays(1)

        }
        
        let stampsLog = repository.diaryForDateInterval(from: start!, to: end!)
        var count = 0

        for stamp in stampsLog {
            if goal.stamps.contains(stamp.stampId) {
                count += 1
            }
        }
        
        return count
    }
    
    // Return the date goal is reached or nil of goals is not reached
    func positiveGoalReachedDate(_ goal: Goal, diary: [Diary]) -> Date? {
        var count = 0
        for stamp in diary {
            if goal.stamps.contains(stamp.stampId) {
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
            if goal.stamps.contains(stamp.stampId) {
                count += 1
                if count > goal.limit {
                    return false
                }
            }
        }
        
        return true
    }
}
