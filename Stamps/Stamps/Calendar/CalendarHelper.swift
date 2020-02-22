//
//  CalendarHelper.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/8/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class CalenderHelper {

    // We will add configuration later where user can choose whether to have Mon...Sun weeks of Sun...Sat
    static let weekStartMonday = true
    
    // Singleton instance
    static let shared = CalenderHelper()

    private var months = [Month]()
    
    private init() {
        // TODO: For now, just create all month for current year
        for i in 1...12 {
            months.append(Month(Date(year: 2020, month: i)))
        }
    }
    
    var numberOfMonths: Int {
        return months.count
    }
    
    func monthAt(_ index: Int) -> Month {
        return months[index]
    }
    
    // Convert index representation of the date into actual simple date structure
    // Handles cases where certain days in a week falls out of the current month and return nil for them
    // For example: if January 1 is Tuesday, calling it for January with week index == 0 and day index == 0 (Monday)
    // will return nil
    func dateFromIndex(month: Int, week: Int, day: Int) -> Date? {
        let dayNum = week * 7 + day - months[month].firstIndex + 1
        if dayNum > 0 && dayNum <= months[month].numberOfDays {
            return Date(year: months[month].year, month: months[month].month, day: dayNum)
        }
        return nil
    }
    
    func labelForDay(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM, d"
        
        return df.string(from: date)
    }

}

extension CalenderHelper {

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
        var numberOfDays = 31
        
        init(_ date: Date) {
            let comps = Calendar.current.dateComponents([.year, .month], from: date)
            self.month = comps.month!
            self.year = comps.year!
            
            recalculateWeeks()
        }
        
        var label: String {
            let calendar = Calendar.sharedCalendarWithSystemTimezone()

            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            
            let df = DateFormatter()
            df.dateFormat = "MMMM"
            
            return df.string(from: calendar.date(from: comps)!)
        }

        // Returns index specific month days fall into (used in AwardManager to detect week that day falls into)
        func indexForDay(_ day: Int) -> Int {
            return (day % 7 + firstIndex - 1) % 7
        }

        func labelsForDaysInWeek(_ weekIdx: Int) -> [String] {
            var res = [String]()
            for i in 0...6 {
                let num = i + (weekIdx*7) - firstIndex + 1
                if num > 0 && num <= numberOfDays {
                    res.append("\(num)")
                }
                else {
                    res.append("")
                }
            }
            return res
        }

        
        func recalculateWeeks() {
            let calendar = Calendar.sharedCalendarWithSystemTimezone()
            var comps = DateComponents.init()
            comps.month = month
            comps.year = year
            comps.day = 1
            
            // Get 1st of the month
            let first = calendar.date(from: comps)!
            // Get weekday for the 1st of the month
            let firstWeekDay = calendar.component(.weekday, from: first)

            // Calendar week day defined starting with Sunday as 1 - we need to transform it to our index,
            // so Monday can be first

            if weekStartMonday == true {
                firstIndex = firstWeekDay == 1 ? 6 : firstWeekDay - 2
            }
            else {
                firstIndex = firstWeekDay - 1
            }
            
            // Get how many days in month we have
            numberOfDays = calendar.range(of: .day, in: .month, for: first)!.count
            
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
}
