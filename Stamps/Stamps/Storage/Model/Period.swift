//
//  Period.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum Period: Int {
    case week
    case month
    case year // not used
    case total // not used
    
    var name: String {
        switch self {
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        case .year:
            return "Annual"
        case .total:
            return "Overall"
        }
    }
}
