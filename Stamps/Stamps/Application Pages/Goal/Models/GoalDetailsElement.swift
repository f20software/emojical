//
//  GoalDetailsElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/2021.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum GoalDetailsElement: Hashable {
    case view(GoalViewData)
    case edit(GoalEditData)
}
