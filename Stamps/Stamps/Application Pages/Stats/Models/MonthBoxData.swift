//
//  WeekLineData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// View model data to display statistics of single stamp during one month
struct MonthBoxData {

    // Primary key
    let primaryKey: UUID
    
    // Stamp information
    let stampId: Int64
    let label: String
    let name: String
    let color: UIColor

    // Weekday header
    let weekdayHeaders: [String]
    
    // Month specific
    let firstDayKey: String // YYYYMMDD - so we can re-create Month object
    let numberOfWeeks: Int
    let firstDayOffset: Int
    
    // Bit mask for the stamp
    let bitsAsString: String // seven 0/1 digits separated by |
}

extension MonthBoxData: Equatable, Hashable {}
