//
//  GoalStreakSortOrder.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 10/03/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Unified view model for statistics collection view
enum GoalStreakSortOrder: Hashable {

    /// Sort by goal reached total count
    case totalCount
    
    /// Sort by streak length
    case streakLength
}
