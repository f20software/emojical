//
//  CalendarHelper.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/8/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class CalendarHelper {

    // We will add configuration later where user can choose whether to have Mon...Sun weeks of Sun...Sat
    static var weekStartMonday = true
    
    // Singleton instance
    static var shared: CalendarHelper! {
        willSet {
            if shared != nil {
                assertionFailure("Calendar helper should be initialized once per application launch")
            }
        }
    }

    init() {
        // Initialize weeks.
        var calendar = Calendar.current
        if CalendarHelper.weekStartMonday {
            calendar.firstWeekday = 2
        }
    }
}

extension CalendarHelper {

    class Year {
        let year: Int
        
        // Most of years will have 53 weeks, but for leap year starting on Sunday - it will be 54
        let numberOfWeeks: Int

        // Convenient shortcuts to Jan 1
        let firstDay: Date

        // Convenient shortcuts to Dec 31
        let lastDay: Date
        
        // 365 for regular years, 366 for the leap ones
        let numberOfDays: Int
        
        // Which day of the week 1st of the month fall into on the calendar view:
        // when Monday is first day if the week: 0 - Monday, 1 - Tuesday ... 6 - Sunday
        // when Sunday is first day if the week: 0 - Sunday, 1 - Monday ... 6 - Saturday
        var firstIndex: Int

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

        var label: String {
            return "\(year)"
        }
    }

    class Month {
        let month: Int
        let year: Int
        
        // Most of month will have 5 weeks, edge cases will be identified in recalculateWeeks() method
        var numberOfWeeks: Int = 5

        // Which day of the week 1st of the month fall into on the calendar view:
        // when Monday is first day if the week: 0 - Monday, 1 - Tuesday ... 6 - Sunday
        // when Sunday is first day if the week: 0 - Sunday, 1 - Monday ... 6 - Saturday
        var firstIndex: Int = 0

        // Number of days in a month, duh
        var numberOfDays: Int

        // Convinience shortcut for the first day of month
        let firstDay: Date

        // Convinience shortcut for the last day of month
        let lastDay: Date
        
        init(_ date: Date) {
            self.month = Calendar.current.component(.month, from: date)
            self.year = Calendar.current.component(.year, from: date)
            
            self.firstDay = Date(year: year, month: month, day: 1)
            self.numberOfDays = Calendar.current.range(of: .day, in: .month, for: firstDay)!.count
            self.lastDay = Date(year: year, month: month, day: numberOfDays)

            recalculateWeeks()
        }
        
        var label: String {
            let df = DateFormatter()
            df.dateFormat = "MMMM, YYYY"
            return df.string(from: Date(year: year, month: month))
        }

        /// Returns index specific month days fall into (used in AwardManager to detect week that day falls into)
        func indexForDay(_ day: Int) -> Int {
            return (day % 7 + firstIndex + 6) % 7
        }
        
        func recalculateWeeks() {
            
            // Get weekday for the 1st of the month
            let firstWeekDay = Calendar.current.component(.weekday, from: firstDay)

            // Calendar week day defined starting with Sunday as 1 - we need to transform it to our index,
            // so Monday can be first
            if weekStartMonday == true {
                firstIndex = firstWeekDay == 1 ? 6 : firstWeekDay - 2
            }
            else {
                firstIndex = firstWeekDay - 1
            }
            
            // Special case for February and 4 weeks
            if (firstIndex == 0 && numberOfDays == 28) {
                numberOfWeeks = 4;
            }
            else {
                // Do we have spill over for 6 weeks or not?
                if (firstIndex + (numberOfDays - 28) > 7) {
                    numberOfWeeks = 6;
                }
            }
        }
    }
    
    class Week {
        let year: Int
        let month: Int
        let weekOfYear: Int
        let label: String

        let firstDay: Date
        let lastDay: Date
        
        init(_ date: Date) {
            var calendar = Calendar.current
            calendar.firstWeekday = CalendarHelper.weekStartMonday ? 2 : 1

            self.month = calendar.component(.month, from: date)
            self.year = calendar.component(.year, from: date)
            self.weekOfYear = calendar.component(.weekOfYear, from: date)
            
            firstDay = Date(
                year: year,
                month: month,
                weekOfYear: weekOfYear,
                weekDay: calendar.firstWeekday,
                calendar: calendar
            )
            
            lastDay = Date(
                year: year,
                month: month,
                weekOfYear: weekOfYear,
                weekDay: calendar.firstWeekday + 6,
                calendar: calendar
            )
            
            // Week label formatting.
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            
            let firstLabel = formatter.string(from: firstDay)
            
            // If the week ends on the same month as it begins, we use short label format,
            // like "Month X - Y". Otherwise we use long label format, like "Month1 X - Month2 Y".
            if calendar.dateComponents([.month], from: firstDay) == calendar.dateComponents([.month], from: lastDay) {
                formatter.dateFormat = "d"
            }
            let secondLabel = formatter.string(from: lastDay)
            
            label = "\(firstLabel) - \(secondLabel)"
        }

        func dayHeadersForWeek() -> [DayHeaderData] {
            let formatter = DateFormatter()
            let today = Date().databaseKey

            return (0..<7).map({
                return firstDay.byAddingDays($0)
            }).map({
                formatter.dateFormat = "d"
                let dayNum = formatter.string(from: $0)
                formatter.dateFormat = "E"
                let weekday = formatter.string(from: $0)
                return DayHeaderData(
                    date: $0,
                    dayNum: dayNum,
                    dayName: weekday,
                    isCurrent: $0.databaseKey == today,
                    isWeekend: $0.isWeekend)
            })
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

        var isCurrentWeek: Bool {
            let todayKey = Date().databaseKey
            
            return (firstDay.databaseKey <= todayKey &&
                lastDay.databaseKey >= todayKey)
        }
    }
}
