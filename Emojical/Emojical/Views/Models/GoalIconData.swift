//
//  GoalIconData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/13/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// View model to show Goal in progress icon
struct GoalIconData {
    let goalId: Int64?
    let emoji: String?
    let backgroundColor: UIColor
    let direction: Direction
    let period: Period
    let progress: Float
    let progressColor: UIColor
}

extension Goal {

    /// Convinience constructor from Goal and current progress object
    func toIconData(progress: Int) -> GoalIconData {
        
        switch direction {
        case .positive:
            let iconProgress = progress >= limit ?
                1.0 : (Float(progress) / Float(limit) + (progress == 0 ? Specs.zeroProgressMock : 0))

            return GoalIconData(
                goalId: id,
                emoji: stickers.first?.label,
                backgroundColor: Theme.main.colors.unreachedGoalBackground,
                direction: direction,
                period: period,
                progress: iconProgress,
                progressColor: Theme.main.colors.positiveGoalProgress
            )
            
        case .negative:
            var iconProgress: Float = 0.0
            var iconBackground = Theme.main.colors.unreachedGoalBackground
            if progress <= limit {
                iconProgress = (progress == 0 ? (1.0 - Specs.zeroNegativeProgressMock) :
                    (Float(limit - progress) / Float(limit) + Specs.zeroProgressMock))
                iconBackground = (stickers.first?.color ?? Theme.main.colors.tint).withAlphaComponent(0.3)
            }

            return GoalIconData(
                goalId: id,
                emoji: stickers.first?.label,
                backgroundColor: iconBackground,
                direction: direction,
                period: period,
                progress: iconProgress,
                progressColor: Theme.main.colors.negativeGoalProgress
            )
        }
    }
}

extension GoalIconData: Equatable, Hashable {}

// MARK: - Specs
fileprivate struct Specs {

    /// Will add this to positive goals, so when current progress is 0, we still show small percentage
    static let zeroProgressMock: Float = 0.03

    /// Will deduct it from 100% for negative goals (when the progress hasn't started) to show that it's not complete circle
    static let zeroNegativeProgressMock: Float = 0.05
}
