//
//  CongratsData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/13/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum GoalOrAwardIconData {
    case goal(data: GoalIconData)
    case award(data: AwardIconData)
    
    init(stamp: Stamp?, goal: Goal, progress: Int) {
        if goal.direction == .positive && progress >= goal.limit {
            self = .award(data: AwardIconData(stamp: stamp))
        }
        else {
            self = .goal(data: GoalIconData(stamp: stamp, goal: goal, progress: progress))
        }
    }
    
    init(award: Award, goal: Goal, stamp: Stamp?) {
        if award.reached {
            self = .award(data: AwardIconData(stamp: stamp))
        } else {
            switch award.direction {
            case .positive:
                self = .goal(data: GoalIconData(
                    stamp: stamp,
                    goal: goal,
                    progress: award.count)
                )
            case .negative:
                self = .award(data: AwardIconData(stamp: stamp, busted: true))
            }
        }
        
    }
}

extension GoalOrAwardIconData: Equatable, Hashable {}
//if award.reached {
//    self.init(
//        goalId: goal.id,
//        emoji: stamp?.label,
//        backgroundColor: (stamp?.color ?? Theme.main.colors.tint).withAlphaComponent(0.5),
//        direction: goal.direction,
//        period: goal.period,
//        progress: 1.0,
//        progressColor: Theme.main.colors.reachedGoalBorder,
//        isReached: true
//    )
//} else {
//    switch award.direction {
//    case .positive:
//        self.init(
//            goalId: goal.id,
//            emoji: stamp?.label,
//            backgroundColor: Theme.main.colors.unreachedGoalBackground,
//            direction: .positive,
//            period: award.period,
//            progress: Float(award.count) / Float(award.limit) + Specs.zeroProgressMock,
//            progressColor: Theme.main.colors.positiveGoalProgress,
//            isReached: false
//        )
//    case .negative:
//        self.init(
//            goalId: goal.id,
//            emoji: stamp?.label,
//            backgroundColor: Theme.main.colors.unreachedGoalBackground,
//            direction: award.direction,
//            period: award.period,
//            // Not reached negative goal means actual count was larger than the limit
//            // so we don't show "progress" (it will be >100%), instead showing clear border
//            progress: 0.0,
//            progressColor: UIColor.clear,
//            isReached: false
//        )
//    }
//}
