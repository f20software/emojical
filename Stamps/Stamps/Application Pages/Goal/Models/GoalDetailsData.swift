//
//  GoalDetailsData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/2021.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct GoalDetailsData {
    let goal: Goal
    let progress: Int
    let award: GoalAwardData
}

extension GoalDetailsData: Equatable, Hashable {}
