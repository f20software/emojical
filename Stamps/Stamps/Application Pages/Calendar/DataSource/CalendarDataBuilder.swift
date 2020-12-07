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
    }
    
    func cells(forStyle style: Style) -> [[CalendarCellData]] {
        switch style {
        case .compact:
            return cellsForMonths(months: calendar.currentMonths)
        case .extended:
            return cellsForWeeks(weeks: calendar.currentWeeks)
        case .today:
            return [cellsForWeek(week: calendar.currentWeeks[calendar.weekIndexForDay(date: Date())!])]
        }
    }
    
    func weekDataForWeek(_ index: Int) -> [DayColumnData] {
        guard index > 0 && index < calendar.currentWeeks.count else { return [] }
        
        let week = calendar.currentWeeks[index]
        let labels = week.dayHeadersForWeek()
        let stickers = weekStickers(week: week).map { $0.map {
            DayStampData(stampId: $0.id, label: $0.label, color: $0.color, isEnabled: true)
        }}

        return zip(labels, stickers).map({ return DayColumnData(header: $0, stamps: $1) })
    }
    
    // MARK: - Private
    
    private func cellsForMonths(months: [CalendarHelper.Month]) -> [[CalendarCellData]] {
        months.enumerated().map { cells(forMonth: $0.1, index: $0.0) }
    }
    
    private func cells(forMonth month: CalendarHelper.Month, index: Int) -> [CalendarCellData] {
        let header = CalendarCellData.header(
            title: calendar.monthAt(index).label,
            monthlyAwards: monthAwards(monthIdx: index, period: .month),
            weeklyAwards: monthAwards(monthIdx: index, period: .week)
        )
        
        let weeks: [CalendarCellData] = (0..<(calendar.monthAt(index).numberOfWeeks)).map { weekIndex in
            CalendarCellData.compactWeek(
                labels: calendar.monthAt(index).labelsForDaysInWeek(weekIndex),
                data: weekColorData(monthIdx: index, weekIdx: weekIndex),
                awards: weekAwardColors(monthIdx: index, weekIdx: weekIndex)
            )
        }
        
        return [header] + weeks
    }
    
    private func cellsForWeeks(weeks: [CalendarHelper.Week]) -> [[CalendarCellData]] {
        weeks.map { cells(forWeek: $0) }
    }
    
    private func cellsForWeek(week: CalendarHelper.Week) -> [CalendarCellData] {
        cells(forWeek: week)
        // daysData(for: week)
    }
    
    private func cells(forWeek week: CalendarHelper.Week) -> [CalendarCellData] {
        let header = CalendarCellData.header(
            title: week.label,
            monthlyAwards: monthAwards(forWeek: week),
            weeklyAwards: weekAwards(forWeek: week)
        )
        
        let week = CalendarCellData.expandedWeek(
            labels: week.labelsForDaysInWeek(),
            data: weekStickers(week: week).map { $0.map { StickerData(label: $0.label, color: $0.color) } },
            awards: weekAwardColors(forWeek: week)
        )
        
        return [header, week]
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
    
    // MARK: - Subclasses
    
    enum Style {
        case compact
        case extended
        case today
        
        static prefix func !(_ value: Style) -> Style {
            switch value {
            case .compact:
                return .extended
            case .extended:
                return .compact
            case .today:
                return .today
                
            }
        }
        
        var action: String {
            switch self {
            case .compact:
                return "Collapse"
            case .extended:
                return "Expand"
            case .today:
                return ""
            }
        }
    }
}
