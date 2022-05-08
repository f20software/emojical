//
//  GoalData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct GoalData {
    let goalId: Int64
    let name: String
    let period: Period
    let details: String
    let count: Int
    let checkMark: Bool
    let icon: GoalOrAwardIconData
}

extension GoalData: Equatable, Hashable {}
