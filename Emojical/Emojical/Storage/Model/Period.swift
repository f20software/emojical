//
//  Period.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum Period: Int {
    /// Weekly goals
    case week
    
    /// Monthly goals
    case month
    
    /// Overall goals - something to reach once
    case once

    /// Annual goals - NOT IMPLEMENTED
    case year
    
    /// Is it periodic goal? Can it have streaks?
    var isPeriodic: Bool {
        return self != .once
    }
}
