//
//  GoalStreakSortOrder.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 10/03/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Unified view model for statistics collection view
enum GoalStatsSortOrder: Hashable {

    /// Sort by goal reached total count
    case totalCount
    
    /// Sort by streak length
    case streakLength
}

extension GoalStatsSortOrder {

    /// Readable column title value
    var columnTitle: String {
        switch self {
        case .totalCount:
            return "total_column".localized
        case .streakLength:
            return "streak_column".localized
        }
    }

    /// Readable report title value
    var title: String {
        switch self {
        case .totalCount:
            return "goal_totals_title".localized
        case .streakLength:
            return "goal_streaks_title".localized
        }
    }
}
