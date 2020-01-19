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
