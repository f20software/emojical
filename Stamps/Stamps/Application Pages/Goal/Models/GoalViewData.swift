//
//  GoalViewData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/2021.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct GoalViewData {

    // Text information to be displayed on the Goal details in view mode
    let title: String
    let details: String
    let statis: String
    let progressText: String
    
    // Final award data and current progress data
    let award: GoalAwardData
    let progress: GoalAwardData
}

extension GoalViewData: Equatable, Hashable {}
