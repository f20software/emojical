//
//  StickersElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Unified view model for stickers/goals collection view
enum StickersElement: Hashable {
    case sticker(StickerData)
    case newSticker
    case goal(GoalData)
    case newGoal
    case noGoals(String)
}
