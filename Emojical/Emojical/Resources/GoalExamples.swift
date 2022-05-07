//
//  StickersGallery.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 5/6/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// List of examples of goals
/// Don't forget to update localization files when editing
let goalExamplesData: [GoalExampleData] = [
    
    GoalExampleData(
        category: "category-Health",
        name: "goal-name-Play Soccer",
        description: "goal-description-Record your soccer practices",
        direction: .positive,
        period: .week,
        limit: 3,
        stickers: [
            StickerExampleData(emoji: "⚽️", name: "sticker-Soccer", color: UIColor(named: "emojiGreen")!)
        ],
        extra: []
    ),
    GoalExampleData(
        category: "category-Health",
        name: "goal-name-Be Active",
        description: "goal-description-Record your activities",
        direction: .positive,
        period: .week,
        limit: 5,
        stickers: [
            StickerExampleData(emoji: "🧘", name: "sticker-Yoga", color: UIColor(named: "emojiYellow")!),
            StickerExampleData(emoji: "⚽️", name: "sticker-Soccer", color: UIColor(named: "emojiGreen")!)
        ],
        extra: []
    ),
    GoalExampleData(
        category: "category-Food",
        name: "goal-name-Eat Less Red Meat",
        description: "goal-description-Record food you eat",
        direction: .negative,
        period: .week,
        limit: 3,
        stickers: [
            StickerExampleData(emoji: "🥩", name: "sticker-Steak", color: UIColor(named: "emojiRed")!),
        ],
        extra: [
            StickerExampleData(emoji: "🐣", name: "sticker-Chicken", color: UIColor(named: "emojiGreen")!),
            StickerExampleData(emoji: "🐟", name: "sticker-Fish", color: UIColor(named: "emojiGreen")!),
            StickerExampleData(emoji: "🥦", name: "sticker-Vegetables", color: UIColor(named: "emojiLightGreen")!),
        ]
    )
]
