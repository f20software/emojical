//
//  DateTests.swift
//  EmojicalTests
//
//  Created by Alexander on 18.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import XCTest
@testable import Emojical

class DateTests: XCTestCase {
    
    override func setUp() { }

    override func tearDown() { }
    
    func calendarInstance(weekStartMonday: Bool) -> Calendar {
        // Initialize calendar with Monday as start of the week.
        var calendar = Calendar.current
        calendar.firstWeekday = weekStartMonday ? 2 : 1
        return calendar
    }
}
