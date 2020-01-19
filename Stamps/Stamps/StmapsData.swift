//
//  StampsData.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/18/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class StampsMonth {
    let month: Int
    let year: Int
    
    var numberOfWeeks: Int = 5
    var firstIndex: Int = 0
    var numDays = 31
    
    init(month: Int, year: Int) {
        self.month = month
        self.year = year
        recalculateWeeks()
    }
    
    var textForMonth: String {
        let calendar = Calendar.sharedCalendarWithSystemTimezone()

        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        
        return df.string(from: calendar.date(from: comps)!)
    }
    
    func textForWeek(_ week: Int) -> [String] {
        var res = [String]()
        for i in 0...6 {
            let num = i + (week*7) - firstIndex + 1
            if num > 0 && num <= numDays {
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
        // Save off index for the Month 1st
        if firstWeekDay == 1 {
            firstIndex = 6
        }
        else {
            firstIndex = firstWeekDay - 2
        }
        
        // Get how many days in month we have
        numDays = calendar.range(of: .day, in: .month, for: first)!.count
        
        // Special case for February and 4 weeks
        if (firstIndex == 0 && numDays == 28) {
            numberOfWeeks = 4;
        }
        else {
            // Do we have spill over for 6 weeks or not?
            if (firstIndex + (numDays - 28) > 7) {
                numberOfWeeks = 6;
            }
        }
    }
}


class StampsData {
    
    var months = [StampsMonth]()
    
    init() {
        months.append(StampsMonth(month: 1, year: 2020))
        months.append(StampsMonth(month: 2, year: 2020))
        months.append(StampsMonth(month: 3, year: 2020))
        months.append(StampsMonth(month: 4, year: 2020))
        months.append(StampsMonth(month: 5, year: 2020))
        months.append(StampsMonth(month: 6, year: 2020))
        months.append(StampsMonth(month: 7, year: 2020))
        months.append(StampsMonth(month: 8, year: 2020))
        months.append(StampsMonth(month: 9, year: 2020))
        months.append(StampsMonth(month: 10, year: 2020))
        months.append(StampsMonth(month: 11, year: 2020))
        months.append(StampsMonth(month: 12, year: 2020))
    }
    
    var numberOfMonth: Int {
        return months.count
    }
    
    func numberOfWeeks(month: Int) -> Int {
        return months[month].numberOfWeeks
    }
    
    func textForWeek(month: Int, week: Int) -> [String] {
        return months[month].textForWeek(week)
    }
    
    func textForMonth(_ month: Int) -> String {
        return months[month].textForMonth
    }
    
    
}
