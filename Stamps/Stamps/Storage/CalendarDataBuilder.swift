//
//  MonthlyDataSource.swift
//  Stamps
//
//  Created by Alexander on 16.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class CalendarDataBuilder {
    
    private let repository: DataRepository
    private let calendar: CalendarHelper
    
    init(repository: DataRepository, calendar: CalendarHelper) {
        self.repository = repository
        self.calendar = calendar
        self.localCache = [:]
    }
    
    func weekDataForWeek(_ week: CalendarHelper.Week) -> [DayColumnData] {
        let labels = week.dayHeadersForWeek()
        let stickers = weekStickers(week: week).map { $0.map {
            DayStampData(stampId: $0.id, label: $0.label, color: $0.color, isEnabled: false)
        }}

        return zip(labels, stickers).map({ return DayColumnData(header: $0, stamps: $1) })
    }
    
    func awardsForWeek(_ week: CalendarHelper.Week) -> [Award] {
        return monthAwards(forWeek: week) + weekAwards(forWeek: week)
    }
    
    // MARK: - Navigation viability
    
    static let secondsInDay = (60 * 60 * 24)
    
    // We allow to move one week forward from the week with last entry (i.e. showing next empty week)
    func canMoveWeekForward(_ week: CalendarHelper.Week) -> Bool {
        let lastEntryDate = repository.getLastDiaryDate() ?? Date()
        let nextWeekFirstDay = week.firstDay.byAddingWeek(1)
        
        let distance = Int(nextWeekFirstDay.timeIntervalSince(lastEntryDate))
        return !(distance > (7 * CalendarDataBuilder.secondsInDay))
    }

    // We allow to move one week back from the week with last entry (i.e. showing one empty week)
    func canMoveWeekBackwards(_ week: CalendarHelper.Week) -> Bool {
        let firstEntryDate = repository.getFirstDiaryDate() ?? Date()
        let prevWeekLastDay = week.lastDay.byAddingWeek(-1)
        
        let distance = Int(firstEntryDate.timeIntervalSince(prevWeekLastDay))
        return !(distance > (7 * CalendarDataBuilder.secondsInDay))
    }

    // Don't allow to move to the next month if there is no data for the next month
    func canMoveMonthForward(_ month: CalendarHelper.Month) -> Bool {
        let lastEntryDate = repository.getLastDiaryDate() ?? Date()
        let nextMonthFirstDay = month.firstDay.byAddingMonth(1)
        
        let distance = Int(nextMonthFirstDay.timeIntervalSince(lastEntryDate))
        return !(distance > 0)
    }

    // Don't allow to move to the previous month if there is no data for the next month
    func canMoveMonthBackwards(_ month: CalendarHelper.Month) -> Bool {
        let firstEntryDate = repository.getFirstDiaryDate() ?? Date()
        let nextMonthLastDay = month.lastDay.byAddingMonth(-1)
        
        let distance = Int(firstEntryDate.timeIntervalSince(nextMonthLastDay))
        return !(distance > 0)
    }

    // MARK: - Getting statistics
    
    /// Retrieve weekly stats for specific week for list of stamps - synchroniously
    func weeklyStatsForWeek(_ week: CalendarHelper.Week, allStamps: [Stamp]) -> [WeekLineData] {
        let diary = repository.diaryForDateInterval(from: week.firstDay, to: week.lastDay)
        return allStamps.compactMap({
            guard let stampId = $0.id else { return nil }
            let bits = (0..<7).map({
                let date = week.firstDay.byAddingDays($0)
                return diary.contains(where: {
                    $0.date.databaseKey == date.databaseKey && $0.stampId == stampId }) ? "1" : "0"
            }).joined(separator: "|")
            
            return WeekLineData(
                stampId: stampId,
                label: $0.label,
                color: $0.color,
                bitsAsString: bits)
        })
    }
    
    /// Creates Monthly stats empty data - actual statistics will be loaded asynchrouniously 
    func emptyStatsDataForMonth(_ month: CalendarHelper.Month, allStamps: [Stamp]) -> [MonthBoxData] {
        let weekdayHeaders = CalendarHelper.Week(Date()).weekdayLettersForWeek()
        
        return allStamps.compactMap({
            guard let stampId = $0.id else { return nil }

            // Create empty bits array for number of days in the month. Actual data will
            // be loaded asynchroniously using `monthlyStatsForStampAsync` call
            let bits = String(repeating: "0|", count: month.numberOfDays-1) + "0"

            return MonthBoxData(
                primaryKey: UUID(),
                stampId: stampId,
                label: $0.label,
                name: $0.name,
                color: $0.color,
                weekdayHeaders: weekdayHeaders,
                firstDayKey: month.firstDay.databaseKey,
                numberOfWeeks: month.numberOfWeeks,
                firstDayOffset: month.firstIndex,
                bitsAsString: bits
            )
        })
    }

    /// Local cache to store already calculated monthly stats
    var localCache: [String:String]
    // TODO: Come up with cache invalidating logic

    /// Asynchronously returns monthly statistics as bit string by stampId and month
    func monthlyStatsForStampAsync(stampId: Int64, month: CalendarHelper.Month,
        completion: @escaping (String) -> Void)
    {
        let key = "\(stampId)-\(month.firstDay.databaseKey)"
        if let local = localCache[key] {
            completion(local)
            return
        }
        
        DispatchQueue.global().async {
            let diary = self.repository.diaryForDateInterval(
                from: month.firstDay, to: month.lastDay, stampId: stampId)
            
            let bits = (0..<month.numberOfDays).map({
                let date = month.firstDay.byAddingDays($0)
                return diary.contains(where: {
                    $0.date.databaseKey == date.databaseKey && $0.stampId == stampId }) ? "1" : "0"
            }).joined(separator: "|")
            // Update local cache before returning
            self.localCache[key] = bits
            completion(bits)
        }
    }
    
    // MARK: - Helpers
    
    // Returns a list of Stamps grouped by day for a given week.
    func weekStickers(week: CalendarHelper.Week) -> [[Stamp]] {
        return (1...7)
        .map({
            return Date(year: week.year, month: week.month, weekOfYear: week.weekOfYear, weekDay: $0)
                .byAddingDays(CalendarHelper.weekStartMonday ? 1 : 0)
        })
        .map({ date in
            repository.stampsIdsForDay(date).compactMap { repository.stampById($0) }
        })
    }
    
    // Helper method to go through seven days (some could be empty) and gather just
    // color data from stamps selected for these days
    func weekColorData(monthIdx: Int, weekIdx: Int) -> [[UIColor]] {
        var res = [[UIColor]]()
        for i in 0..<7 {
            let date = calendar.dateFromIndex(month: monthIdx, week: weekIdx, day: i)
            // Invalid date? Bail our early
            if date == nil {
                res.append([])
                continue
            }

            var colors = [UIColor]()
            for stamp in repository.stampsIdsForDay(date!) {
                colors.append(repository.stampById(stamp)!.color)
            }
            
            res.append(colors)
        }
        
        return res
    }
    
    func weekColorData(week: CalendarHelper.Week) -> [[UIColor]] {
        weekStickers(week: week).map { $0.map { $0.color } }
    }
    
    func weekLabelData(week: CalendarHelper.Week) -> [[String]] {
        weekStickers(week: week).map { $0.map { $0.label } }
    }
    
    // Helper method to go through a week of awards and gather just colors
    func weekAwardColors(monthIdx: Int, weekIdx: Int) -> [UIColor] {
        var res = [UIColor]()
        
        if let dateEnd = calendar.dateFromIndex(month: monthIdx, week: weekIdx, day: 6) {
            let awards = repository.weeklyAwardsForInterval(start: dateEnd.byAddingDays(-6), end: dateEnd)
            for award in awards {
                res.append(repository.colorForAward(award))
            }
        }
        
        return res
    }

    // Helper method to get monthly awards
    func monthAwards(monthIdx: Int, period: Period) -> [Award] {
        let month = calendar.monthAt(monthIdx)
        let date = Date(year: month.year, month: month.month)

        let awards = period == .month
            ? repository.monthlyAwardsForMonth(date: date)
            : repository.weeklyAwardsForMonth(date: date)
        let sorted = awards.sorted { (a1, a2) -> Bool in
            return a1.goalId < a2.goalId
        }

        return sorted
    }
    
    // Returns a list of awards earned on a given week
    func monthAwards(forWeek week: CalendarHelper.Week) -> [Award] {
        return repository
            .monthlyAwardsForInterval(start: week.firstDay, end: week.lastDay)
            .sorted { (a1, a2) -> Bool in
                return a1.goalId < a2.goalId
            }
    }
    
    func weekAwards(forWeek week: CalendarHelper.Week) -> [Award] {
        return repository
            .weeklyAwardsForInterval(start: week.firstDay, end: week.lastDay)
            .sorted { (a1, a2) -> Bool in
                return a1.goalId < a2.goalId
            }
    }
    
    func weekAwardColors(forWeek week: CalendarHelper.Week) -> [UIColor] {
        return repository
            .weeklyAwardsForInterval(start: week.firstDay, end: week.lastDay)
            .map { repository.colorForAward($0) }
    }
}
