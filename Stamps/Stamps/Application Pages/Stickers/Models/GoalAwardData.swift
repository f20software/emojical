//
//  GoalAwardData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct GoalAwardData {
    let goalId: Int64
    let name: String
    let details: String
    let count: Int
    let color: UIColor
    let dashes: Int
    let progress: CGFloat
    let progressColor: UIColor
}

extension GoalAwardData: Equatable, Hashable {}
