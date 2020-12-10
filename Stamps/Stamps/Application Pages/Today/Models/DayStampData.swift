//
//  DayStampData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct DayStampData {
    let stampId: Int64?
    let label: String
    let color: UIColor
    let isUsed: Bool
}

extension DayStampData: Equatable, Hashable {}
