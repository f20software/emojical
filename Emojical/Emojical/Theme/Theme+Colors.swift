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

    class Colors {
    
        /// Main application tint color
        let tint = UIColor(named: "tint")!

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
        let separator = UIColor(named: "formSeparator")!
        
        /// Shadow color for sticker selector and plus button on the Today screen
        let shadow = UIColor(named: "plateShadow")!

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
            UIColor(named: "emojiRed")!,
            UIColor(named: "emojiViolet")!,
            UIColor(named: "emojiYellow")!,
            UIColor(named: "emojiLightGreen")!,
            UIColor(named: "emojiGreen")!,
            UIColor(named: "emojiLightBlue")!,
            UIColor(named: "emojiBlue")!,
        ]
        
        // MARK: - Goals and awards colors
        
        /// Positive goal progress bar
        let positiveGoalProgress = UIColor(named: "positiveGoalProgress")!
        
        /// Negative goal progress bar
        let negativeGoalProgress = UIColor(named: "negativeGoalProgress")!
        
        /// Reached goal award border color
        let reachedGoalBorder = UIColor(named: "reachedGoalBorder")!
        
        /// Unreached goal background (whether it's positive goal in progress or busted negative goal)
        let unreachedGoalBackground = UIColor(named: "unreachedGoalBackground")!
    }
}
