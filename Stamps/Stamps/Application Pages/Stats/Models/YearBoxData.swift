//
//  YearBoxData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// View model data to display statistics of single stamp during one year
struct YearBoxData {

    // Primary key
    let primaryKey: UUID
    
    // Stamp information
    let stampId: Int64
    let label: String
    let name: String
    let color: UIColor

    // Weekday and month header
    let weekdayHeaders: [String]
    let monthHeaders: [String]

    // Year specific
    let year: Int
    let numberOfWeeks: Int
    let firstDayOffset: Int
    
    // Bit mask for the stamp
    let bitsAsString: String // 365/6 0/1 digits separated by |
}

extension YearBoxData: Equatable, Hashable {}
