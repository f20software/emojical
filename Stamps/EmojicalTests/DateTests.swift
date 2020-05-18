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

    func test_beginningOfTheWeek_januaryFirstWithMonday() {
        let calendar = calendarInstance(weekStartMonday: true)
        let date = Date(year: 2020, month: 1, day: 1)
        
        let beginningOfWeek = date.beginningOfWeek(inCalendar: calendar)
        let components = calendar.dateComponents([.month, .day], from: beginningOfWeek)
        
        XCTAssert(components.month! == 12 && components.day! == 30)
    }
    
    func test_beginningOfTheWeek_decemberLastWithMonday() {
        let calendar = calendarInstance(weekStartMonday: true)
        let date = Date(year: 2019, month: 12, day: 31)
        
        let beginningOfWeek = date.beginningOfWeek(inCalendar: calendar)
        let components = calendar.dateComponents([.month, .day], from: beginningOfWeek)
        
        XCTAssert(components.month! == 12 && components.day! == 30)
    }
    
    func test_beginningOfTheWeek_januaryFirstWithSunday() {
        let calendar = calendarInstance(weekStartMonday: false)
        let date = Date(year: 2020, month: 1, day: 1)
        
        let beginningOfWeek = date.beginningOfWeek(inCalendar: calendar)
        let components = calendar.dateComponents([.month, .day], from: beginningOfWeek)
        
        XCTAssert(components.month! == 12 && components.day! == 29)
    }
    
    func test_beginningOfTheWeek_decemberLastWithSunday() {
        let calendar = calendarInstance(weekStartMonday: false)
        let date = Date(year: 2019, month: 12, day: 31)
        
        let beginningOfWeek = date.beginningOfWeek(inCalendar: calendar)
        let components = calendar.dateComponents([.month, .day], from: beginningOfWeek)
        
        XCTAssert(components.month! == 12 && components.day! == 29)
    }
    
    // MARK: - Private helpers
    
    func calendarInstance(weekStartMonday: Bool) -> Calendar {
        // Initialize calendar with Monday as start of the week.
        var calendar = Calendar.current
        calendar.firstWeekday = weekStartMonday ? 2 : 1
        return calendar
    }
}
