//
//  GoalOrAwardIconData.swift
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
    init(goal: Goal, progress: Int) {
        if goal.direction == .positive && progress >= goal.limit {
            self = .award(data: goal.toAwardIconData())
        }
        else {
            self = .goal(data: goal.toIconData(progress: progress))
        }
    }
    
    /// Constructor from received or failed Award - used to generate Recap data
    init(award: Award, goal: Goal) {
        if award.reached {
            self = .award(data: award.toIconData())
        } else {
            switch award.direction {
            case .positive:
                self = .goal(data: goal.toIconData(progress: award.count))
            case .negative:
                self = .award(data: award.toIconData())
            }
        }
        
    }
}

extension GoalOrAwardIconData: Equatable, Hashable {}
