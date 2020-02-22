//
//  DateExtensions.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/18/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

extension Calendar {
    static var _instance: Calendar?
    static func sharedCalendarWithSystemTimezone() -> Calendar {
        if _instance == nil {
            _instance = Calendar.init(identifier: .gregorian)
            _instance!.timeZone = TimeZone.current
            _instance!.locale = Locale(identifier: Locale.preferredLanguages.first!)
        }
        
        return _instance!
    }
}

extension Date {
    
    // This date format is used to store date into database and sort records
    var yyyyMmDd: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
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
    
    func byAddingDays(_ days: Int) -> Date {
        return self.advanced(by: TimeInterval(days * 24 * 60 * 60))
    }
}
