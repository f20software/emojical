//
//  WeekHeaderData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// View model data to display weekday header (used in Weekly view)
struct WeekHeaderData {
    let weekdayHeaders: [String]
}

extension WeekHeaderData: Equatable, Hashable {}
