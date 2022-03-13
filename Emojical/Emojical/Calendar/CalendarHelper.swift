//
//  CalendarHelper.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/8/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class CalendarHelper {

    // Right now we will support in the code only two options - week
    // can start either on Monday and end on Sunday or start on Sunday and end on Saturday
    enum WeekStartOption {
        case monday
        case sunday
    }
    
    // Default value is Monday through Sunday
    static var weekStartDay: WeekStartOption = .monday
    
    // Singleton instance
    static var shared: CalendarHelper! {
        willSet {
            if shared != nil {
                assertionFailure("Calendar helper should be initialized once per application launch")
            }
        }
    }

    init() {
        // Update current calendar with a proper firstWeekday property
        var calendar = Calendar.current
        switch CalendarHelper.weekStartDay {
        case .monday:
            calendar.firstWeekday = 2
        case .sunday:
            calendar.firstWeekday = 1
        }
    }
}

extension CalendarHelper {

    // MARK: - Year
    
    /// Class encapsulating a Year. Provides easy access for the first and last day of it,
    /// number of weeks, based on `weekStartDay` option in CalendarHelper class.
    class Year {

        /// Year value
        let year: Int
        
        /// Most of the years will have 53 weeks, but for leap year starting on Sunday - it will be 54
        let numberOfWeeks: Int

        /// Convenient shortcuts to Jan 1
        let firstDay: Date

        /// Convenient shortcuts to Dec 31
        let lastDay: Date
        
        /// 365 for regular years, 366 for the leap ones
        let numberOfDays: Int
        
        /// Which day of the week 1st of the month fall into on the calendar view:
        /// when Monday is first day if the week: 0 - Monday, 1 - Tuesday ... 6 - Sunday
        /// when Sunday is first day if the week: 0 - Sunday, 1 - Monday ... 6 - Saturday
        let firstIndex: Int

        init(_ year: Int) {
            self.year = year
            self.firstDay = Date(year: year, month: 1, day: 1)
            self.lastDay = Date(year: year, month: 12, day: 31)
            
            let calendar: Calendar = .autoupdatingCurrent
            let days = calendar.ordinality(of: .day, in: .year, for: lastDay) ?? 365
            self.numberOfDays = days
            
            // Use January Month object to calculate first day offset
            let jan = Month(firstDay)
            self.firstIndex = jan.firstIndex
            
            if jan.firstIndex == 6 && days == 366 {
                self.numberOfWeeks = 54
            } else {
                self.numberOfWeeks = 53
            }
        }
        
        convenience init(_ date: Date) {
            self.init(Calendar.current.component(.year, from: date))
        }

        /// Label for the year in a "2021" format
        var label: String {
            return "\(year)"
        }
    }

    // MARK: - Month

    /// Class encapsulating a Month. Provides easy access for the first and last day of it,
    /// number of weeks, and index for the first day based on `weekStartDay` option in CalendarHelper class.
    class Month {

        /// Year value
        let year: Int

        /// Month index (1 - January, 12 - December)
        let month: Int
        
        /// Number of days in a month, duh
        let numberOfDays: Int

        /// Convinience shortcut for the first day of month
        let firstDay: Date

        /// Convinience shortcut for the last day of month
        let lastDay: Date

        /// Number of weeks in the month (based on `weekStartDay` option).
        /// Most of month will have 5 weeks, edge cases will be identified in recalculateWeeks() method.
        private (set) var numberOfWeeks: Int!

        /// Which day of the week 1st of the month fall into on the calendar view:
        /// when Monday is first day if the week: 0 - Monday, 1 - Tuesday ... 6 - Sunday
        /// when Sunday is first day if the week: 0 - Sunday, 1 - Monday ... 6 - Saturday
        private (set) var firstIndex: Int!

        init(_ date: Date) {
            self.month = Calendar.current.component(.month, from: date)
            self.year = Calendar.current.component(.year, from: date)
            
            self.firstDay = Date(year: year, month: month, day: 1)
            self.numberOfDays = Calendar.current.range(of: .day, in: .month, for: firstDay)!.count
            self.lastDay = Date(year: year, month: month, day: numberOfDays)
            self.numberOfWeeks = recalculateWeeks()
        }
        
        /// Label for the month in a "January 2021" format
        var label: String {
            let df = DateFormatter()
            df.dateFormat = "MMMM, YYYY"
            return df.string(from: Date(year: year, month: month))
        }

        /// Returns index specific month days fall into (used in AwardManager to detect week that day falls into)
        func indexForDay(_ day: Int) -> Int {
            return (day % 7 + firstIndex + 6) % 7
        }
        
        /// Initializes internal properties for the number of weeks, first day index etc
        private func recalculateWeeks() -> Int {
            
            // Get weekday for the 1st of the month
            let firstWeekDay = Calendar.current.component(.weekday, from: firstDay)

            // Calendar week day defined starting with Sunday as 1
            // - we need to transform it to our index, so Monday can be first
            var index = 0
            if weekStartDay == .monday {
                index = firstWeekDay == 1 ? 6 : firstWeekDay - 2
            }
            else {
                index = firstWeekDay - 1
            }
            self.firstIndex = index
            
            // Special case for February and 4 weeks
            var weeksNum = 5
            if (firstIndex == 0 && numberOfDays == 28) {
                weeksNum = 4;
            }
            else {
                // Do we have spill over for 6 weeks or not?
                if ((firstIndex + (numberOfDays - 28)) > 7) {
                    weeksNum = 6;
                }
            }
            
            return weeksNum
        }
    }
    
    // MARK: - Week

    /// Class encapsulating a Week. Provides easy access for the first and last day of it,
    /// based on `weekStartDay` option in CalendarHelper class.
    class Week {

        /// Convinience shortcut for the first day of week
        let firstDay: Date

        /// Convinience shortcut for the last day of week
        let lastDay: Date

        init(_ date: Date) {
            self.lastDay = date.lastOfWeek
            self.firstDay = lastDay.byAddingDays(-6)
        }

        /// Returns `true` when today date falls into this week range
        var isCurrentWeek: Bool {
            let todayKey = Date().databaseKey
            
            return (firstDay.databaseKey <= todayKey &&
                lastDay.databaseKey >= todayKey)
        }
        
        /// Returns `true` when week start is in a future
        var isFuture: Bool {
            let todayKey = Date().databaseKey
            
            return (firstDay.databaseKey > todayKey)
        }

        /// Label for the week in a "December 21 - 28" or "December 28 - January 3" format
        var label: String {
            let formatter = DateIntervalFormatter()

            formatter.locale = Locale(identifier:
                Bundle.main.preferredLocalizations.first ?? "en")
            formatter.dateTemplate = "MMMMd"
            return formatter.string(from: firstDay, to: lastDay)
        }

        /// Returns array of days for all dates within the week
        var days: [Date] {
            return (0..<7).map { firstDay.byAddingDays($0) }
        }
        
        func dayHeadersForWeek(highlightedIndex: Int) -> [DayHeaderData] {
            let formatter = DateFormatter()
            let today = Date().databaseKey

            var result: [DayHeaderData] = self.days.map {
                formatter.dateFormat = "d"
                let dayNum = formatter.string(from: $0)
                formatter.dateFormat = "E"
                let weekday = formatter.string(from: $0)
                
                return DayHeaderData(
                    date: $0,
                    dayNum: dayNum,
                    dayName: weekday,
                    isToday: $0.databaseKey == today,
                    isWeekend: $0.isWeekend,
                    isHighlighted: false)
            }
            
            if highlightedIndex >= 0 {
                result[highlightedIndex].isHighlighted = true
            }
            return result
        }

        func weekdayLettersForWeek() -> [String] {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"

            return (0..<7).map({
                return firstDay.byAddingDays($0)
            }).map({
                formatter.dateFormat = "E"
                let weekday = formatter.string(from: $0)
                return String(weekday.prefix(1)).capitalized
            })
        }
    }
}
