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
    
    // MARK: - Today View data building
    
    /// Build data model for the single week for Today view
    func weekDataModel(for week: CalendarHelper.Week) -> [DayColumnData] {
        let labels = week.dayHeadersForWeek()
        let stickers = weekStickers(week: week).map { $0.map {
            DayStampData(
                stampId: $0.id,
                label: $0.label,
                color: $0.color,
                isUsed: false
            )
        }}

        return zip(labels, stickers).map({ return DayColumnData(header: $0, stamps: $1) })
    }
    
    /// Retrieve monthly and weeky awards for the week
    func awards(for week: CalendarHelper.Week) -> [Award] {
        return monthAwards(forWeek: week) + weekAwards(forWeek: week)
    }
    
    // MARK: - Navigation viability
    
    static let secondsInDay = (60 * 60 * 24)
    
    // We allow to move one week forward from the week with last entry (i.e. showing next empty week)
    func canMoveForward(_ week: CalendarHelper.Week) -> Bool {
        let lastEntryDate = repository.getLastDiaryDate() ?? Date()
        let nextWeekFirstDay = week.firstDay.byAddingWeek(1)
        
        let distance = Int(nextWeekFirstDay.timeIntervalSince(lastEntryDate))
        return !(distance > (7 * CalendarDataBuilder.secondsInDay))
    }

    // We allow to move one week back from the week with last entry (i.e. showing one empty week)
    func canMoveBackward(_ week: CalendarHelper.Week) -> Bool {
        let firstEntryDate = repository.getFirstDiaryDate() ?? Date()
        let prevWeekLastDay = week.lastDay.byAddingWeek(-1)
        
        let distance = Int(firstEntryDate.timeIntervalSince(prevWeekLastDay))
        return !(distance > (7 * CalendarDataBuilder.secondsInDay))
    }

    // Don't allow to move to the next month if there is no data for the next month
    func canMoveForward(_ month: CalendarHelper.Month) -> Bool {
        let lastEntryDate = repository.getLastDiaryDate() ?? Date()
        let nextMonthFirstDay = month.firstDay.byAddingMonth(1)
        
        let distance = Int(nextMonthFirstDay.timeIntervalSince(lastEntryDate))
        return !(distance > 0)
    }

    // Don't allow to move to the previous month if there is no data for the next month
    func canMoveBackward(_ month: CalendarHelper.Month) -> Bool {
        let firstEntryDate = repository.getFirstDiaryDate() ?? Date()
        let nextMonthLastDay = month.lastDay.byAddingMonth(-1)
        
        let distance = Int(firstEntryDate.timeIntervalSince(nextMonthLastDay))
        return !(distance > 0)
    }

    // Don't allow to move to the next year if there is no data for the next month
    func canMoveForward(_ year: CalendarHelper.Year) -> Bool {
        let lastEntryDate = repository.getLastDiaryDate() ?? Date()
        let nextYearFirstDay = year.firstDay.byAddingMonth(12)
        
        let distance = Int(nextYearFirstDay.timeIntervalSince(lastEntryDate))
        return !(distance > 0)
    }

    // Don't allow to move to the previous year if there is no data for the next month
    func canMoveBackward(_ year: CalendarHelper.Year) -> Bool {
        let firstEntryDate = repository.getFirstDiaryDate() ?? Date()
        let nextYearLastDay = year.lastDay.byAddingMonth(-12)
        
        let distance = Int(firstEntryDate.timeIntervalSince(nextYearLastDay))
        return !(distance > 0)
    }

    // MARK: - Stats page data building
    
    /// Retrieve weekly stats for specific week for list of stamps - synchroniously
    func weeklyStats(for week: CalendarHelper.Week, allStamps: [Stamp]) -> [WeekLineData] {
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
    func emptyStatsData(for month: CalendarHelper.Month, stamps: [Stamp]) -> [MonthBoxData] {
        let weekdayHeaders = CalendarHelper.Week(Date()).weekdayLettersForWeek()
        
        return stamps.compactMap({
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
    
    /// Creates Year stats empty data - actual statistics will be loaded asynchrouniously
    func emptyStatsData(for year: CalendarHelper.Year, stamps: [Stamp]) -> [YearBoxData] {
        let weekdayHeaders = CalendarHelper.Week(Date()).weekdayLettersForWeek()
        
        return stamps.compactMap({
            guard let stampId = $0.id else { return nil }

            // Create empty bits array for number of days in the month. Actual data will
            // be loaded asynchroniously using `monthlyStatsForStampAsync` call
            let bits = String(repeating: "0|", count: year.numberOfDays-1) + "0"

            return YearBoxData(
                primaryKey: UUID(),
                stampId: stampId,
                label: $0.label,
                name: $0.name,
                color: $0.color,
                weekdayHeaders: weekdayHeaders,
                monthHeaders: [""],
                year: year.year,
                numberOfWeeks: year.numberOfWeeks,
                firstDayOffset: year.firstIndex,
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

    // TODO: !!!! Need to be optimized a lot
    /// Asynchronously returns monthly statistics as bit string by stampId and month
    func yearlyStatsForStampAsync(stampId: Int64, year: CalendarHelper.Year,
        completion: @escaping (String) -> Void)
    {
        let key = "\(stampId)-\(year.year)"
        if let local = localCache[key] {
            completion(local)
            return
        }
        
        DispatchQueue.global().async {
            let diary = self.repository.diaryForDateInterval(
                from: year.firstDay, to: year.lastDay, stampId: stampId)
            
            let bits = (0..<year.numberOfDays).map({
                let date = year.firstDay.byAddingDays($0)
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
    
    // Returns a list of awards earned on a given week
    private func monthAwards(forWeek week: CalendarHelper.Week) -> [Award] {
        return repository
            .monthlyAwardsForInterval(start: week.firstDay, end: week.lastDay)
            .sorted { (a1, a2) -> Bool in
                return a1.goalId < a2.goalId
            }
    }
    
    private func weekAwards(forWeek week: CalendarHelper.Week) -> [Award] {
        return repository
            .weeklyAwardsForInterval(start: week.firstDay, end: week.lastDay)
            .sorted { (a1, a2) -> Bool in
                return a1.goalId < a2.goalId
            }
    }
}
