//
//  EmojicalTests.swift
//  EmojicalTests
//
//  Created by Vladimir Svidersky on 3/15/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import XCTest

class EmojicalTests: XCTestCase {

    override func setUp() {
        // Default setting is for week from Monday to Sunday
        CalenderHelper.weekStartMonday = true
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
            XCTAssertEqual(CalenderHelper.shared.endOfMonth(date: date).databaseKey, testData[date]![0])
            let prev = date.byAddingMonth(-1)
            XCTAssertEqual(CalenderHelper.shared.endOfMonth(date: prev).databaseKey, testData[date]![1])
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
            XCTAssertEqual(CalenderHelper.shared.endOfWeek(date: date).databaseKey, testData[date]![1])
            XCTAssertEqual(CalenderHelper.shared.endOfMonth(date: date).databaseKey, testData[date]![2])
        }
    }

    func testCalendarHelperSaturday() {
        CalenderHelper.weekStartMonday = false
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
            XCTAssertEqual(CalenderHelper.shared.endOfWeek(date: date).databaseKey, testData[date]![1])
            XCTAssertEqual(CalenderHelper.shared.endOfMonth(date: date).databaseKey, testData[date]![2])
        }
    }
    
    func testIndexFromDay() {
        
        let testData: [Date: (IndexPath, Int)] = [
            Date(year: 2020, month: 2, day: 12): (IndexPath(row: 2, section: 1), 2),
            Date(year: 2020, month: 2, day: 1): (IndexPath(row: 0, section: 1), 5),
            Date(year: 2020, month: 2, day: 29): (IndexPath(row: 4, section: 1), 5),
            Date(year: 2020, month: 3, day: 1): (IndexPath(row: 0, section: 2), 6),
            Date(year: 2020, month: 3, day: 15): (IndexPath(row: 2, section: 2), 6),
            Date(year: 2020, month: 3, day: 30): (IndexPath(row: 5, section: 2), 0),
        ]
        
        for date in testData.keys {
            print(date.databaseKey)
            let result = CalenderHelper.shared.indexForDay(date: date)
            XCTAssertEqual(result!.0.section, testData[date]!.0.section)
            XCTAssertEqual(result!.0.row, testData[date]!.0.row)
            XCTAssertEqual(result!.1, testData[date]!.1)
        }

    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
