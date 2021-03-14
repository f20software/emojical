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
    
    /// Constructor from the in-progress Goal - used in Today's current week awards and in the list of Goals
    init(stamp: Stamp?, goal: Goal, progress: Int) {
        if goal.direction == .positive && progress >= goal.limit {
            self = .award(data: AwardIconData(stamp: stamp, goalId: goal.id))
        }
        else {
            self = .goal(data: GoalIconData(stamp: stamp, goal: goal, progress: progress))
        }
    }
    
    /// Constructor from received or failed Award - used to generate Recap data
    init(award: Award, goal: Goal, stamp: Stamp?) {
        if award.reached {
            self = .award(data: AwardIconData(stamp: stamp, goalId: goal.id))
        } else {
            switch award.direction {
            case .positive:
                self = .goal(data: GoalIconData(
                    stamp: stamp,
                    goal: goal,
                    progress: award.count)
                )
            case .negative:
                self = .award(data: AwardIconData(stamp: stamp, goalId: goal.id, busted: true))
            }
        }
        
    }
}

extension GoalOrAwardIconData: Equatable, Hashable {}
