//
//  GoalEditData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct GoalEditData {
    let goal: Goal
    let stickers: [String]
    let award: GoalAwardData
}

extension GoalEditData: Equatable, Hashable {}
