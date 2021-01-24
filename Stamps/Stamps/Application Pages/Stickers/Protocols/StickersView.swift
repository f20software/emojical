//
//  StickersView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickersView: AnyObject {

    /// User tapped on the sticker
    var onStickerTapped: ((Int64) -> Void)? { get set }

    /// User tapped on the goal
    var onGoalTapped: ((Int64) -> Void)? { get set }

    /// User tapped on the create new goal
    var onNewGoalTapped: (() -> Void)? { get set }

    /// User tapped on the create new sticker
    var onNewStickerTapped: (() -> Void)? { get set }

    /// User tapped on Add button
    var onAddButtonTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Load stats for the month
    func loadData(stickers: [StickerData], goals: [GoalData])
}
