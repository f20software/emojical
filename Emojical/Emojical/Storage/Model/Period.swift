//
//  Period.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum Period: Int {
    /// Weekly goals
    case week
    
    /// Monthly goals
    case month
    
    /// Overall goals - something to reach once
    case once

    /// Annual goals - NOT IMPLEMENTED
    case year
}

/// Language extension
extension Period {

    /// Returns section title for the goal period type
    var sectionTitle: String {
        switch self {
        case .week: return "weekly_goal_section_title".localized
        case .month: return "monthly_goal_section_title".localized
        case .once: return "once_goal_section_title".localized
        default:
            assertionFailure("Not implemented")
            return ""
        }
    }
    
    /// Goal from period. For example - "weekly goal"
    var goal: String {
        switch self {
        case .week: return "weekly_goal".localized
        case .month: return "monthly_goal".localized
        case .once: return "once_goal".localized
        default:
            assertionFailure("Not implemented")
            return ""
        }
    }
}
 
extension Period: CaseIterable {}

