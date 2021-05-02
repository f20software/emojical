//
//  GoalStreakData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/04/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct GoalStreakData {
    let goalId: Int64
    let name: String
    let details: String
    let count: Int
    let history: [Bool]
    let icon: GoalOrAwardIconData
}

struct GoalStreakData2 {
    let goalId: Int64
    let period: Period
    let count: Int
    let streak: Int
    let icon: GoalOrAwardIconData
}

extension GoalStreakData: Equatable, Hashable {}
extension GoalStreakData2: Equatable, Hashable {}
