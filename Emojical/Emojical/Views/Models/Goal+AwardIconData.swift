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
}

extension GoalOrAwardIconData: Equatable, Hashable {}
