//
//  GoalViewData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct GoalViewData {
    // Text information to be displayed on the Goal details in view mode
    let details: String
    let stickers: [String]
    let progressText: String
    
    // Final award data and current progress data
    let awardIcon: AwardIconData
    let goalIcon: GoalIconData
}

extension GoalViewData: Equatable, Hashable {}
