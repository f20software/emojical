//
//  Theme+Colors.swift
//  Emojical
//
//  Created by Vladimit Svidersky on 02/06/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

extension Theme {

    enum Palette : String {
        case red = "EF476F"
        case violet = "D671DB"
        case yellow = "FFE175"
        case lightGreen = "83D483"
        case green = "049F70"
        case lightBlue = "118AB2"
        case blue = "202674"
    }
    
    class Colors {
    
        /// Main application tint color
        lazy var tint: UIColor = {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                return UITraitCollection.userInterfaceStyle == .light ?
                    UIColor(hex: "202674") : UIColor(hex: "C3D9FA")
            }
        }()

        // MARK: - Backgrounds
        
        /// Main application background
        let background = UIColor.systemBackground

        /// Second background (used for cell plates, dates etc)
        let secondaryBackground = UIColor.systemGray6

        /// Highlighted day background
        let calendarHighlightedBackground = UIColor.darkGray
        
        /// Today day background
        let calendarTodayBackground = UIColor.systemRed
        
        /// Separator color
        lazy var separator: UIColor = {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                return UITraitCollection.userInterfaceStyle == .light ?
                    UIColor.separator.withAlphaComponent(0.1) : UIColor.separator
            }
        }()
        
        /// Shadow color for sticker selector and plus button on the Today screen
        lazy var shadow: UIColor = {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                return UITraitCollection.userInterfaceStyle == .light ?
                    UIColor.gray : UIColor.clear
            }
        }()

        // MARK: - Text colors
        
        /// Main text color
        let text = UIColor.label

        /// Secondary (lighter text color)
        let secondaryText = UIColor.secondaryLabel
        
        /// Weekend text color in calendar
        let weekendText = UIColor.systemRed

        /// Section header text color
        let sectionHeaderText = UIColor.secondaryLabel

        // MARK: - Color palette
        
        /// Application color pallete
        let palette:[UIColor] = [
            UIColor(hex: "EF476F"), // red
            UIColor(hex: "D671DB"), // violet
            UIColor(hex: "FFE175"), // yellow
            UIColor(hex: "83D483"), // light green
            UIColor(hex: "049F70"), // green
            UIColor(hex: "118AB2"), // light blue
            UIColor(hex: "202674")  // blue
        ]
        
        // MARK: - Goals and awards colors
        
        /// Positive goal progress bar
        let positiveGoalProgress = UIColor(hex: "83D483") // light green
        
        /// Negative goal progress bar
        let negativeGoalProgress = UIColor(hex: "118AB2") // light blue
        
        /// Goal reached border color
        lazy var goalReachedBorder: UIColor = {
            return self.tint.withAlphaComponent(0.8)
        }()
        
        /// Goal reached border color
        lazy var failedGoalBackground: UIColor = {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                return UITraitCollection.userInterfaceStyle == .light ?
                    UIColor.darkGray.withAlphaComponent(0.2) :
                    UIColor.lightGray.withAlphaComponent(0.2)
            }
        }()
    }
}
