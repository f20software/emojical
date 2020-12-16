//
//  GoalAwardData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// View model to show goal / award data
struct GoalAwardData {
    let goalId: Int64?
    let emoji: String?
    let backgroundColor: UIColor
    let direction: Direction
    let progress: Float
    let progressColor: UIColor
}

extension GoalAwardData: Equatable, Hashable {}

extension GoalAwardData {
    
    // Build GoalAwardData model for already received award
    init(award: Award, goal: Goal, stamp: Stamp?) {
        self.init(
            goalId: goal.id,
            emoji: stamp?.label,
            backgroundColor: (stamp?.color ?? UIColor.appTintColor).withAlphaComponent(0.5),
            direction: goal.direction,
            progress: 1.0,
            progressColor: UIColor.darkGray
        )
    }
    
    // Build GoalAwardData model from the Goal, progress and Stamp object
    init(goal: Goal, progress: Int, stamp: Stamp?) {
        // Will add this to positive goals, so when current progress is 0,
        // we still show small percentage
        let zeroProgressMock: Float = 0.03
        
        // Will deduct it from 100% for negative goals (when the progress
        // hasn't started) to show that it's not complete circle
        let zeroNegativeProgressMock: Float = 0.05

        switch goal.direction {
        case .positive:
            if progress >= goal.limit {
                // You got it - should match award render mode
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: (stamp?.color ?? UIColor.appTintColor).withAlphaComponent(0.5),
                    direction: .positive,
                    progress: 1.0,
                    progressColor: UIColor.darkGray
                )
            } else {
                // Still have some work to do
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: UIColor.systemGray.withAlphaComponent(0.2),
                    direction: .positive,
                    progress: Float(progress) / Float(goal.limit) + zeroProgressMock,
                    progressColor: UIColor.positiveGoalNotReached
                )
            }
        case .negative:
            if progress > goal.limit {
                // Busted
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: UIColor.systemGray.withAlphaComponent(0.2),
                    direction: .negative,
                    progress: 0.0,
                    progressColor: UIColor.clear
                )
            } else {
                // Still have some room to go
                let percent = progress == 0 ?
                        (1.0 - zeroNegativeProgressMock) :
                        (Float(goal.limit - progress) / Float(goal.limit) + zeroProgressMock)
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: (stamp?.color ?? UIColor.appTintColor).withAlphaComponent(0.3),
                    direction: .negative,
                    progress: percent,
                    progressColor: UIColor.negativeGoalNotReached
                )
            }
        }
    }
}

