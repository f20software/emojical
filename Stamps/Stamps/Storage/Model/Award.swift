//
//  Award.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct Award {
    // Default award badge color - should not really happen ever
    static let defaultColor = UIColor.red

    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    let goalId: Int64 // FK to Goals table
    let date: Date
    
    var earnedOnText: String {
        let df = DateFormatter()
        df.dateStyle = .long
        
        return "Earned on \(df.string(from: date))"
    }
}
