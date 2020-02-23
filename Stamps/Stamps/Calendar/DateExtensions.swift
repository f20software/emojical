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
    
    // Convinience constructor when we have only date components
    init(year: Int, month: Int, day: Int = 1) {
        var comps = DateComponents.init()
        comps.month = month
        comps.year = year
        comps.day = day
        comps.hour = 12
        comps.minute = 0
        comps.second = 0
        
        self = Calendar.current.date(from: comps) ?? Date()
    }
    
    // Shift date by number of days
    func byAddingDays(_ days: Int) -> Date {
        return self.advanced(by: TimeInterval(days * 24 * 60 * 60))
    }
}
