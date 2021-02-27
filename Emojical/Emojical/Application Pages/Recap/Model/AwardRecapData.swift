//
//  AwardRecapData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

struct AwardRecapData {
    let title: String
    let progress: GoalOrAwardIconData
}

extension AwardRecapData: Equatable, Hashable {}
