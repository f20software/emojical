//
//  EmojicalTests.swift
//  EmojicalTests
//
//  Created by Vladimir Svidersky on 3/15/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import XCTest
@testable import Emojical

class EmojicalTests: XCTestCase {

    override func setUp() {
        // Default setting is for week from Monday to Sunday
        if CalendarHelper.shared == nil {
            CalendarHelper.shared = CalendarHelper(from: Date(year: 2020, month: 1, day: 20),
                                               to: Date(year: 2020, month: 10, day: 20))
        }
        CalendarHelper.weekStartMonday = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLastMonthDay() {
        // Date: end of current month, end of previous month
        let testData: [Date: [String]] = [
            Date(year: 2020, month: 2, day: 12): ["2020-02-29", "2020-01-31"],
            Date(year: 2020, month: 3, day: 30): ["2020-03-31", "2020-02-29"],
            Date(year: 2020, month: 1, day: 1): ["2020-01-31", "2019-12-31"],
            Date(year: 2019, month: 12, day: 31): ["2019-12-31", "2019-11-30"],
        ]

        for date in testData.keys {
            XCTAssertEqual(CalendarHelper.shared.endOfMonth(date: date).databaseKey, testData[date]![0])
            let prev = date.byAddingMonth(-1)
            XCTAssertEqual(CalendarHelper.shared.endOfMonth(date: prev).databaseKey, testData[date]![1])
        }
    }

    func testCalendarHelper() {
        // Date: databaseKey, end of week, end of month
        let testData: [Date: [String]] = [
            Date(year: 2020, month: 2, day: 12): ["2020-02-12", "2020-02-16", "2020-02-29"],
            Date(year: 2020, month: 2, day: 1): ["2020-02-01", "2020-02-02", "2020-02-29"],
            Date(year: 2020, month: 2, day: 29): ["2020-02-29", "2020-03-01", "2020-02-29"],
            Date(year: 2020, month: 3, day: 1): ["2020-03-01", "2020-03-01", "2020-03-31"],
            Date(year: 2020, month: 3, day: 15): ["2020-03-15", "2020-03-15", "2020-03-31"],
            Date(year: 2020, month: 3, day: 31): ["2020-03-31", "2020-04-05", "2020-03-31"],
        ]

        for date in testData.keys {
            XCTAssertEqual(date.databaseKey, testData[date]![0])
            XCTAssertEqual(CalendarHelper.shared.endOfWeek(date: date).databaseKey, testData[date]![1])
            XCTAssertEqual(CalendarHelper.shared.endOfMonth(date: date).databaseKey, testData[date]![2])
        }
    }

    func testCalendarHelperSaturday() {
        CalendarHelper.weekStartMonday = false
        // Date: databaseKey, end of week, end of month
        let testData: [Date: [String]] = [
            Date(year: 2020, month: 2, day: 12): ["2020-02-12", "2020-02-15", "2020-02-29"],
            Date(year: 2020, month: 2, day: 1): ["2020-02-01", "2020-02-01", "2020-02-29"],
            Date(year: 2020, month: 2, day: 29): ["2020-02-29", "2020-02-29", "2020-02-29"],
            Date(year: 2020, month: 3, day: 1): ["2020-03-01", "2020-03-07", "2020-03-31"],
            Date(year: 2020, month: 3, day: 15): ["2020-03-15", "2020-03-21", "2020-03-31"],
            Date(year: 2020, month: 3, day: 31): ["2020-03-31", "2020-04-04", "2020-03-31"],
        ]

        for date in testData.keys {
            XCTAssertEqual(date.databaseKey, testData[date]![0])
            XCTAssertEqual(CalendarHelper.shared.endOfWeek(date: date).databaseKey, testData[date]![1])
            XCTAssertEqual(CalendarHelper.shared.endOfMonth(date: date).databaseKey, testData[date]![2])
        }
    }
    
    func testIndexFromDay() {
        var date = Date(year: 2020, month: 1, day: 1)
        let res = CalendarHelper.shared.indexForDay(date: date)
        var weekIdx = res!.0.row
        var dayIdx = res!.1

        /// Going through all 2020 year and comparing day and week index to what it shoud be
        /// if we will increment them one by one
        for _ in 0...1000 {
            let oldMonth = Calendar.current.component(.month, from: date)
            date = date.byAddingDays(1)
            let newMonth = Calendar.current.component(.month, from: date)
            
            if newMonth == oldMonth {
                dayIdx = dayIdx + 1
                if dayIdx == 7 {
                    dayIdx = 0
                    weekIdx = weekIdx + 1
                }
            }
            else {
                dayIdx = dayIdx + 1
                if dayIdx == 7 {
                    dayIdx = 0
                }
                weekIdx = 1
            }
            
            let test = CalendarHelper.shared.indexForDay(date: date)
            XCTAssert(test!.0.row == weekIdx, "Week index failed for \(date)")
            XCTAssert(test!.1 == dayIdx, "Day index failed for \(date)")
        }
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
