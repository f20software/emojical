//
//  EmojicalTests.swift
//  EmojicalTests
//
//  Created by Vladimir Svidersky on 3/15/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import XCTest
@testable import Emojical

class LocalizationTests: XCTestCase {

    override func setUp() {
        // Default setting is for week from Monday to Sunday
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStickerExampleTranslation() {
        stickerGalleryData.forEach { data in
            let stickerName = data[1].localized
            XCTAssertNotEqual(data[1], stickerName)
        }
    }

    func testGoalExampleTranslation() {
        goalExamplesData.forEach { goal in
            XCTAssertNotEqual(goal.name, goal.name.localized)
            XCTAssertNotEqual(goal.category, goal.category.localized)
            XCTAssertNotEqual(goal.description, goal.description.localized)
            goal.stickers.forEach { sticker in
                XCTAssertNotEqual(sticker.name, sticker.name.localized)
            }
        }
    }
}
