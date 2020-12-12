//
//  GoalAwardData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// View model to show goal / award data
struct GoalAwardData {
    let goalId: Int64?
    let emoji: String?
    let backgroundColor: UIColor
    let direction: Direction
    let progress: Float
    let progressColor: UIColor
}

extension GoalAwardData: Equatable, Hashable {}
