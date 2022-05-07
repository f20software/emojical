//
//  GoalsElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/2022.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Unified view model for stickers/goals collection view
enum GoalsElement: Hashable {
    case goal(GoalData)
    case newGoal
    case noGoals(NoGoalsData)
}
