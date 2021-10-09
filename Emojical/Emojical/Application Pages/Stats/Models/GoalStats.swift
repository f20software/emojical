//
//  GoalStats.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/04/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct GoalStats {
    let goalId: Int64
    let period: Period
    let count: Int
    let streak: Int
    let icon: GoalOrAwardIconData
    let chart: GoalChartData?
}

extension GoalStats: Equatable, Hashable {}
