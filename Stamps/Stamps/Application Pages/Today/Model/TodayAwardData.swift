//
//  TodayAwardData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct TodayAwardData {
    let goalId: Int64
    let color: UIColor
    let dashes: Int
}

extension TodayAwardData: Equatable, Hashable {}
