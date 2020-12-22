//
//  DateExtensions.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/18/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

extension Date {
    
    // This date format is used to store date into database and sort records
    // YYYY-MM-DD with leading zeros for month and day
    var databaseKey: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    var monthKey: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return String(df.string(from: self).prefix(7))
    }
    
    var databaseKeyWithTime: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.string(from: self)
    }

    // Convinience constructor when we have only date components
    init(year: Int, month: Int, day: Int = 1) {
        var comps = DateComponents.init()
        comps.month = month
        comps.year = year
        comps.day = day
        comps.hour = 22
        comps.minute = 0
        comps.second = 0
        
        self = Calendar.current.date(from: comps) ?? Date()
    }
    
    // Convinience constructor from week of year + week day
    init(year: Int, month: Int, weekOfYear: Int, weekDay: Int, calendar: Calendar = Calendar.current) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.weekOfYear = weekOfYear
        components.hour = 22
        components.minute = 0
        components.second = 0
        components.weekday = weekDay
        
        self = calendar.date(from: components) ?? Date()
    }
    
    init(yyyyMmDd: String) {
        let comps = yyyyMmDd.split(separator: "-").map({ Int(String($0))! })
        if comps.count == 3 {
            self = Date(year: comps[0], month: comps[1], day: comps[2])
        }
        else {
            self = Date()
        }
    }
    
    // Shift date by number of days
    func byAddingDays(_ days: Int) -> Date {
        return self.advanced(by: TimeInterval(days * 24 * 60 * 60))
    }

    // Shift date by number of month
    func byAddingMonth(_ months: Int) -> Date {
        var comp = DateComponents()
        comp.month = months
        return Calendar.current.date(byAdding: comp, to: self)!
    }
    
    // Shift date by number of month
    func byAddingWeek(_ weeks: Int) -> Date {
        var comp = DateComponents()
        comp.day = 7 * weeks
        return Calendar.current.date(byAdding: comp, to: self)!
    }
    
    // Simple helper property to recognize that date is today
    var isToday: Bool {
        return self.databaseKey == Date().databaseKey
    }
    
    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1 || weekday == 7
    }
    
    /// Returns first date of the month for the date
    var firstOfMonth: Date {
        let comps = Calendar.current.dateComponents([.year, .month], from: self)
        return Date(year: comps.year!, month: comps.month!)
    }

    /// Returns last day of the month for the date
    var lastOfMonth: Date {
        return firstOfMonth.byAddingMonth(1).byAddingDays(-1)
    }

    /// Returns last date of the week (Sunday or Saturday) based on CalendarHelper setting and selected month
    var lastOfWeek: Date {
        let month = CalendarHelper.Month(self)
        let dayIndex = month.indexForDay(Calendar.current.component(.day, from: self))
        return self.byAddingDays(6-dayIndex)
    }
}
