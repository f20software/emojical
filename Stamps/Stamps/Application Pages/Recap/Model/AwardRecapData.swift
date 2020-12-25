//
//  GoalData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct AwardRecapData {
    let progress: GoalAwardData
    let title: String
}

extension AwardRecapData: Equatable, Hashable {}
