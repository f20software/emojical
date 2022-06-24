//
//  EmojicalTests.swift
//  EmojicalTests
//
//  Created by Vladimir Svidersky on 3/15/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import XCTest
@testable import Emojical

class CalendarTests: XCTestCase {

    override func setUp() {
        // Default setting is for week from Monday to Sunday
        if CalendarHelper.shared == nil {
            CalendarHelper.shared = CalendarHelper()
        }
        CalendarHelper.weekStartDay = .monday
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
            XCTAssertEqual(date.lastOfMonth.databaseKey, testData[date]![0])
            let prev = date.byAddingMonth(-1)
            XCTAssertEqual(prev.lastOfMonth.databaseKey, testData[date]![1])
        }
    }

    func testLastOfWeek_LastOfMonth_Monday() {
        CalendarHelper.weekStartDay = .monday

        // Date: databaseKey, end of week, end of month
        let testData: [Date: [String]] = [
            Date(year: 2020, month: 2, day: 12): ["2020-02-12", "2020-02-16", "2020-02-29"],
            Date(year: 2020, month: 2, day: 1): ["2020-02-01", "2020-02-02", "2020-02-29"],
            Date(year: 2020, month: 2, day: 29): ["2020-02-29", "2020-03-01", "2020-02-29"],
            Date(year: 2020, month: 3, day: 1): ["2020-03-01", "2020-03-01", "2020-03-31"],
            Date(year: 2020, month: 3, day: 15): ["2020-03-15", "2020-03-15", "2020-03-31"],
            Date(year: 2020, month: 3, day: 31): ["2020-03-31", "2020-04-05", "2020-03-31"],
            Date(year: 2020, month: 9, day: 29): ["2020-09-29", "2020-10-04", "2020-09-30"],
            Date(year: 2020, month: 8, day: 25): ["2020-08-25", "2020-08-30", "2020-08-31"],
            Date(year: 2020, month: 8, day: 1): ["2020-08-01", "2020-08-02", "2020-08-31"],
            Date(year: 2020, month: 6, day: 30): ["2020-06-30", "2020-07-05", "2020-06-30"],
            Date(year: 2020, month: 5, day: 25): ["2020-05-25", "2020-05-31", "2020-05-31"],
            Date(year: 2020, month: 4, day: 30): ["2020-04-30", "2020-05-03", "2020-04-30"],
            Date(year: 2021, month: 1, day: 1): ["2021-01-01", "2021-01-03", "2021-01-31"],
        ]

        for date in testData.keys {
            XCTAssertEqual(date.databaseKey, testData[date]![0])
            XCTAssertEqual(date.lastOfWeek.databaseKey, testData[date]![1])
            XCTAssertEqual(date.lastOfMonth.databaseKey, testData[date]![2])
        }
    }

    func testWeekStartEnd_Monday() {
        CalendarHelper.weekStartDay = .monday

        // Date: databaseKey, start and end of the week which that date falls into
        let testData: [Date: [String]] = [
            Date(year: 2020, month: 2, day: 12): ["2020-02-12", "2020-02-10", "2020-02-16"],
            Date(year: 2020, month: 2, day: 1): ["2020-02-01", "2020-01-27", "2020-02-02"],
            Date(year: 2020, month: 2, day: 29): ["2020-02-29", "2020-02-24", "2020-03-01"],
            Date(year: 2020, month: 3, day: 1): ["2020-03-01", "2020-02-24", "2020-03-01"],
            Date(year: 2020, month: 3, day: 15): ["2020-03-15", "2020-03-09", "2020-03-15"],
            Date(year: 2020, month: 3, day: 31): ["2020-03-31", "2020-03-30", "2020-04-05"],
            Date(year: 2020, month: 9, day: 29): ["2020-09-29", "2020-09-28", "2020-10-04"],
            Date(year: 2020, month: 8, day: 25): ["2020-08-25", "2020-08-24", "2020-08-30"],
            Date(year: 2020, month: 8, day: 1): ["2020-08-01", "2020-07-27", "2020-08-02"],
            Date(year: 2020, month: 6, day: 30): ["2020-06-30", "2020-06-29", "2020-07-05"],
            Date(year: 2020, month: 5, day: 25): ["2020-05-25", "2020-05-25", "2020-05-31"],
            Date(year: 2020, month: 4, day: 30): ["2020-04-30", "2020-04-27", "2020-05-03"],
            Date(year: 2021, month: 1, day: 1): ["2021-01-01", "2020-12-28", "2021-01-03"],
            Date(year: 2021, month: 1, day: 2): ["2021-01-02", "2020-12-28", "2021-01-03"],
            Date(year: 2021, month: 1, day: 3): ["2021-01-03", "2020-12-28", "2021-01-03"],
            Date(year: 2021, month: 1, day: 4): ["2021-01-04", "2021-01-04", "2021-01-10"],
        ]

        for date in testData.keys {
            XCTAssertEqual(date.databaseKey, testData[date]![0])
            
            let week = CalendarHelper.Week(date)
            XCTAssertEqual(week.firstDay.databaseKey, testData[date]![1])
            XCTAssertEqual(week.lastDay.databaseKey, testData[date]![2])
        }
    }

    func testWeekStartEnd_Sunday() {
        CalendarHelper.weekStartDay = .sunday

        // Date: databaseKey, start and end of the week which that date falls into
        let testData: [Date: [String]] = [
            Date(year: 2020, month: 2, day: 12): ["2020-02-12", "2020-02-09", "2020-02-15"],
            Date(year: 2020, month: 2, day: 1): ["2020-02-01", "2020-01-26", "2020-02-01"],
            Date(year: 2020, month: 2, day: 29): ["2020-02-29", "2020-02-23", "2020-02-29"],
            Date(year: 2020, month: 3, day: 1): ["2020-03-01", "2020-03-01", "2020-03-07"],
            Date(year: 2020, month: 3, day: 15): ["2020-03-15", "2020-03-15", "2020-03-21"],
            Date(year: 2020, month: 3, day: 31): ["2020-03-31", "2020-03-29", "2020-04-04"],
            Date(year: 2020, month: 9, day: 29): ["2020-09-29", "2020-09-27", "2020-10-03"],
            Date(year: 2020, month: 8, day: 25): ["2020-08-25", "2020-08-23", "2020-08-29"],
            Date(year: 2020, month: 8, day: 1): ["2020-08-01", "2020-07-26", "2020-08-01"],
            Date(year: 2020, month: 6, day: 30): ["2020-06-30", "2020-06-28", "2020-07-04"],
            Date(year: 2020, month: 5, day: 25): ["2020-05-25", "2020-05-24", "2020-05-30"],
            Date(year: 2020, month: 4, day: 30): ["2020-04-30", "2020-04-26", "2020-05-02"],
            Date(year: 2021, month: 1, day: 1): ["2021-01-01", "2020-12-27", "2021-01-02"],
            Date(year: 2021, month: 1, day: 2): ["2021-01-02", "2020-12-27", "2021-01-02"],
            Date(year: 2021, month: 1, day: 3): ["2021-01-03", "2021-01-03", "2021-01-09"],
            Date(year: 2021, month: 1, day: 4): ["2021-01-04", "2021-01-03", "2021-01-09"],
        ]

        for date in testData.keys {
            XCTAssertEqual(date.databaseKey, testData[date]![0])
            
            let week = CalendarHelper.Week(date)
            XCTAssertEqual(week.firstDay.databaseKey, testData[date]![1])
            XCTAssertEqual(week.lastDay.databaseKey, testData[date]![2])
        }
    }

    func testCalendarHelperSaturday() {
        CalendarHelper.weekStartDay = .sunday
        
        // Date: databaseKey, end of week, end of month
        let testData: [Date: [String]] = [
            Date(year: 2020, month: 2, day: 12): ["2020-02-12", "2020-02-15", "2020-02-29"],
            Date(year: 2020, month: 2, day: 1): ["2020-02-01", "2020-02-01", "2020-02-29"],
            Date(year: 2020, month: 2, day: 29): ["2020-02-29", "2020-02-29", "2020-02-29"],
            Date(year: 2020, month: 3, day: 1): ["2020-03-01", "2020-03-07", "2020-03-31"],
            Date(year: 2020, month: 3, day: 15): ["2020-03-15", "2020-03-21", "2020-03-31"],
            Date(year: 2020, month: 3, day: 31): ["2020-03-31", "2020-04-04", "2020-03-31"],
            Date(year: 2020, month: 9, day: 29): ["2020-09-29", "2020-10-03", "2020-09-30"],
            Date(year: 2020, month: 8, day: 25): ["2020-08-25", "2020-08-29", "2020-08-31"],
            Date(year: 2020, month: 8, day: 1): ["2020-08-01", "2020-08-01", "2020-08-31"],
            Date(year: 2020, month: 6, day: 30): ["2020-06-30", "2020-07-04", "2020-06-30"],
            Date(year: 2020, month: 5, day: 25): ["2020-05-25", "2020-05-30", "2020-05-31"],
            Date(year: 2020, month: 4, day: 30): ["2020-04-30", "2020-05-02", "2020-04-30"],
        ]

        for date in testData.keys {
            XCTAssertEqual(date.databaseKey, testData[date]![0])
            XCTAssertEqual(date.lastOfWeek.databaseKey, testData[date]![1])
            XCTAssertEqual(date.lastOfMonth.databaseKey, testData[date]![2])
        }
    }
}
