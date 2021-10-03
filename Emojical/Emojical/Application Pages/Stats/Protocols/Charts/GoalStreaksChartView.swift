//
//  GoalStreaksView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 9/19/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalStreaksChartView: AnyObject {

    /// User tapped on total/streak counters
    var onCountersTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Load stats for the goal streaks
    func loadGoalStreaksData(data: [GoalStreakData2], sortOrder: GoalStreakSortOrder)
}
