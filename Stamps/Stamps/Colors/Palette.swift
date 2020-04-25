//
//  Palette.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/1/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension UIColor {

    // Palette for configuring colors
    static let colorPalette = [
        "EF476F", // red
        "D671DB", // violet
        "FFE175", // yellow
        "83D483", // light green
        "049F70", // green
        "118AB2", // light blue
        "202674"  // blue
    ]

    // Goals progress colors
    static let positiveGoalReached = UIColor(hex: "049F70") // green
    static let negativeGoalReached = UIColor(hex: "202674") // blue
    static let positiveGoalNotReached = UIColor(hex: "83D483") // light green
    static let negativeGoalNotReached = UIColor(hex: "118AB2") // light blue
    
    // When creating new sticker
    static let defaultStickerColor = "FFE175" // yellow
}
