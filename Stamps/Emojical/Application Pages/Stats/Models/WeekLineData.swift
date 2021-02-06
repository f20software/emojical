//
//  WeekLineData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// View model data to display statistics of single stamp during one week
struct WeekLineData {
    let stampId: Int64
    let label: String
    let color: UIColor
    let bitsAsString: String // seven 0/1 digits separated by |
}

extension WeekLineData: Equatable, Hashable {}
