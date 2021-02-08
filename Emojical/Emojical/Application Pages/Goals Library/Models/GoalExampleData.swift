//
//  GoalData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct StickerExampleData {
    let emoji: String
    let name: String
    let color: Theme.Palette
}

struct GoalExampleData {
    let category: String
    let name: String
    let description: String
    let direction: Direction
    let period: Period
    let limit: Int
    let stickers: [StickerExampleData]
    let extra: [StickerExampleData]
}

extension StickerExampleData: Equatable, Hashable {}
extension GoalExampleData: Equatable, Hashable {}
