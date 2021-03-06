//
//  TodayAwardElement.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/17/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum TodayAwardElement: Hashable {
    case award(GoalOrAwardIconData)
    case noAwards(String)
}
