//
//  Direction.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Goal direction
enum Direction: Int {
    
    /// Positive goal - need to reach `limit`
    case positive
    
    /// Negative goal - cannot overcome `limit`
    case negative
}
