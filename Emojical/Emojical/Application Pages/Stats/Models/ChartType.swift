//
//  ChartType.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum ChartType: Int, Hashable {
    
    /// Monthly stats by sticker
    case monthlyStickers

    /// List of goals with their streaks
    case goalStreak
}

/// Convinience properties
extension ChartType {
    
    var title: String {
        switch self {
        case .monthlyStickers:
            return "Monthly Stickers"
            
        case .goalStreak:
            return "Goals Streaks"
        }
    }
    
    var viewControllerId: String {
        switch self {
        case .monthlyStickers:
            return "MonthlyStickers"
        case .goalStreak:
            return "GoalStreaks"
        }
    }
}
