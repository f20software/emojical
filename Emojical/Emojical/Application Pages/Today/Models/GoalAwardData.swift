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
    let period: Period
    let progress: Float
    let progressColor: UIColor
    let isReached: Bool

    static func < (lhs: GoalAwardData, rhs: GoalAwardData) -> Bool {
        // First compare isReached - if it's reached - put them first
        if lhs.isReached != rhs.isReached {
            return lhs.isReached
        }
        
        // Then compare period - weekly first
        if lhs.period != rhs.period {
            return lhs.period.rawValue < rhs.period.rawValue
        }
        
        // Rest - use Ids to compare 
        return ((lhs.goalId ?? 0) < (rhs.goalId ?? 0))
    }
}

extension GoalAwardData: Equatable, Hashable {}

extension GoalAwardData {

    /// Builds GoalAwardData model for already received award for reached goal
    /// Used: Goal editing screen to show how reached award will look like
    init(goal: Goal, stamp: Stamp?) {
        self.init(
            goalId: goal.id,
            emoji: stamp?.label,
            backgroundColor: (stamp?.color ?? Theme.shared.colors.tint).withAlphaComponent(0.5),
            direction: goal.direction,
            period: goal.period,
            progress: 1.0,
            progressColor: Theme.shared.colors.goalReachedBorder,
            isReached: true
        )
    }
            
    /// Build GoalAwardData model for already received award whether goal was reached or not
    /// Used: Displaying past goals on Today screen and on RecapWeek view
    init(award: Award, goal: Goal, stamp: Stamp?) {
        if award.reached {
            self.init(
                goalId: goal.id,
                emoji: stamp?.label,
                backgroundColor: (stamp?.color ?? Theme.shared.colors.tint).withAlphaComponent(0.5),
                direction: goal.direction,
                period: goal.period,
                progress: 1.0,
                progressColor: Theme.shared.colors.goalReachedBorder,
                isReached: true
            )
        } else {
            switch award.direction {
            case .positive:
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: Theme.shared.colors.failedGoalBackground,
                    direction: .positive,
                    period: award.period,
                    progress: Float(award.count) / Float(award.limit) + Specs.zeroProgressMock,
                    progressColor: Theme.shared.colors.positiveGoalProgress,
                    isReached: false
                )
            case .negative:
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: Theme.shared.colors.failedGoalBackground,
                    direction: award.direction,
                    period: award.period,
                    // Not reached negative goal means actual count was larger than the limit
                    // so we don't show "progress" (it will be >100%), instead showing clear border
                    progress: 0.0,
                    progressColor: UIColor.clear,
                    isReached: false
                )
            }
        }
    }
    
    /// Builds GoalAwardData model from the Goal, progress and Stamp object
    /// Used: Current goas in Today view
    init(goal: Goal, progress: Int, stamp: Stamp?) {

        switch goal.direction {
        case .positive:
            if progress >= goal.limit {
                // You got it - should match award render mode
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: (stamp?.color ?? Theme.shared.colors.tint).withAlphaComponent(0.5),
                    direction: .positive,
                    period: goal.period,
                    progress: 1.0,
                    progressColor: Theme.shared.colors.goalReachedBorder,
                    isReached: true
                )
            } else {
                // Still have some work to do
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: Theme.shared.colors.failedGoalBackground,
                    direction: .positive,
                    period: goal.period,
                    progress: Float(progress) / Float(goal.limit) +
                        (progress == 0 ? Specs.zeroProgressMock : 0),
                    progressColor: Theme.shared.colors.positiveGoalProgress,
                    isReached: false
                )
            }
        case .negative:
            if progress > goal.limit {
                // Busted
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: Theme.shared.colors.failedGoalBackground,
                    direction: .negative,
                    period: goal.period,
                    progress: 0.0,
                    progressColor: UIColor.clear,
                    isReached: false
                )
            } else {
                // Still have some room to go
                let percent = progress == 0 ?
                    (1.0 - Specs.zeroNegativeProgressMock) :
                    (Float(goal.limit - progress) / Float(goal.limit) + Specs.zeroProgressMock)
                self.init(
                    goalId: goal.id,
                    emoji: stamp?.label,
                    backgroundColor: (stamp?.color ?? Theme.shared.colors.tint).withAlphaComponent(0.3),
                    direction: .negative,
                    period: goal.period,
                    progress: percent,
                    progressColor: Theme.shared.colors.negativeGoalProgress,
                    isReached: false
                )
            }
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Will add this to positive goals, so when current progress is 0, we still show small percentage
    static let zeroProgressMock: Float = 0.03

    /// Will deduct it from 100% for negative goals (when the progress hasn't started) to show that it's not complete circle
    static let zeroNegativeProgressMock: Float = 0.05
}
