//
//  Theme+Main.swift
//  FMClient
//
//  Created by Alexander Rogachev on 01.06.2020.
//  Copyright © 2020 Feed Me LLC. All rights reserved.
//

import Foundation
import UIKit

extension Theme {

    /// Returns refault theme.
    static func main() -> Theme {

        let light = Colors(
            
            /// Main application tint color
            tint: UIColor(r: 13, g: 15, b: 45),

            /// Main application background
            background: UIColor.systemBackground,
            
            /// Second background (used for cell plates, dates etc)
            secondaryBackground: UIColor.systemGray6,
            
            /// Main text color
            text: UIColor.label,

            /// Secondary (lighter text color)
            secondaryText: UIColor.secondaryLabel,
            
            /// Application color pallete
            pallete: [
                UIColor(hex: "EF476F"), // red
                UIColor(hex: "D671DB"), // violet
                UIColor(hex: "FFE175"), // yellow
                UIColor(hex: "83D483"), // light green
                UIColor(hex: "049F70"), // green
                UIColor(hex: "118AB2"), // light blue
                UIColor(hex: "202674")  // blue
            ]
        )

        let dark = Colors(
            /// Main application tint color
            tint: UIColor(r: 66, g: 77, b: 227),
            
            /// Main application background
            background: UIColor.systemBackground,
            
            /// Second background (used for cell plates, dates etc)
            secondaryBackground: UIColor.systemGray6,
            
            /// Main text color
            text: UIColor.label,

            /// Secondary (lighter text color)
            secondaryText: UIColor.lightGray,

            /// Application color pallete
            pallete: [
                UIColor(hex: "EF476F"), // red
                UIColor(hex: "D671DB"), // violet
                UIColor(hex: "FFE175"), // yellow
                UIColor(hex: "83D483"), // light green
                UIColor(hex: "049F70"), // green
                UIColor(hex: "118AB2"), // light blue
                UIColor(hex: "202674")  // blue
            ]
        )

        return Theme(lightColors: light, darkColors: dark)
    }
}
