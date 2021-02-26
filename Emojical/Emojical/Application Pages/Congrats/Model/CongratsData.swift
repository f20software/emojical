//
//  CongratsData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/13/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct CongratsData {
    let title: String
    let text: String
    let goalIcon: GoalIconData
    let awardIcon: AwardIconData
}

/// View model to show goal / award data
struct GoalIconData {
    let emoji: String?
    let backgroundColor: UIColor
    let direction: Direction
    let period: Period
    let progress: Float
    let progressColor: UIColor
}

/// View model to show goal / award data
struct AwardIconData {
    let emoji: String?
    let backgroundColor: UIColor
    let borderColor: UIColor
}

extension GoalIconData {
    
    // Convinience constructor from Stamp, Goal and current progress object
    init(stamp: Stamp?, goal: Goal, progress: Int) {
        switch goal.direction {
        case .positive:
            if progress >= goal.limit {
                // You got it - should match award render mode
                self.init(
                    emoji: stamp?.label,
                    backgroundColor: Theme.main.colors.failedGoalBackground,
                    direction: .positive,
                    period: goal.period,
                    progress: 1.0,
                    progressColor: Theme.main.colors.positiveGoalProgress
                )
            } else {
                // Still have some work to do
                self.init(
                    emoji: stamp?.label,
                    backgroundColor: Theme.main.colors.failedGoalBackground,
                    direction: .positive,
                    period: goal.period,
                    progress: Float(progress) / Float(goal.limit) +
                        (progress == 0 ? Specs.zeroProgressMock : 0),
                    progressColor: Theme.main.colors.positiveGoalProgress
                )
            }
        case .negative:
            if progress > goal.limit {
                // Busted
                self.init(
                    emoji: stamp?.label,
                    backgroundColor: Theme.main.colors.failedGoalBackground,
                    direction: .negative,
                    period: goal.period,
                    progress: 0.0,
                    progressColor: UIColor.clear
                )
            } else {
                // Still have some room to go
                let percent = progress == 0 ?
                    (1.0 - Specs.zeroNegativeProgressMock) :
                    (Float(goal.limit - progress) / Float(goal.limit) + Specs.zeroProgressMock)
                self.init(
                    emoji: stamp?.label,
                    backgroundColor: (stamp?.color ?? Theme.main.colors.tint).withAlphaComponent(0.3),
                    direction: .negative,
                    period: goal.period,
                    progress: percent,
                    progressColor: Theme.main.colors.negativeGoalProgress
                )
            }
        }
    }
}

extension AwardIconData {

    // Convinience constructor from Stamp object
    init(stamp: Stamp?) {
        self.init(
            emoji: stamp?.label,
            backgroundColor: (stamp?.color ?? Theme.main.colors.tint).withAlphaComponent(0.5),
            borderColor: Theme.main.colors.goalReachedBorder
        )
    }
}

extension AwardIconData: Equatable, Hashable {}
extension GoalIconData: Equatable, Hashable {}

// MARK: - Specs
fileprivate struct Specs {

    /// Will add this to positive goals, so when current progress is 0, we still show small percentage
    static let zeroProgressMock: Float = 0.03

    /// Will deduct it from 100% for negative goals (when the progress hasn't started) to show that it's not complete circle
    static let zeroNegativeProgressMock: Float = 0.05
}
