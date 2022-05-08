//
//  GoalStatsChartView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 9/19/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalStatsChartView: AnyObject {

    /// Load stats for the goal streaks
    func loadGoalsData(data: [GoalStats], sortOrder: GoalStatsSortOrder)
}
