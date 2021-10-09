//
//  Theme+Specs.swift
//  Emojical
//
//  Created by Vladimit Svidersky on 02/06/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

extension Theme {

    /// Application common specs
    struct Specs {
    
        /// Corner radius for the cells on all lists
        let platesCornerRadius: CGFloat = 8.0
        
        /// Line width for the progress around award icon (small size - used in most of lists)
        let progressWidthSmall: CGFloat = 3.0

        /// Gap between progress line and icon background (for small borders)
        let progressGapSmall: CGFloat = 2.0

        /// Line width for the progress around award icon (medium size - used in details screens and cheers messages)
        let progressWidthMedium: CGFloat = 4.0

        /// Gap between progress line and icon background (for medium borders)
        let progressGapMedium: CGFloat = 3.0

        /// Line width for the progress around award icon (large size - used in Recap)
        let progressWidthLarge: CGFloat = 6.0

        /// Gap between progress line and icon background (for large borders)
        let progressGapLarge: CGFloat = 2.0

        /// Counters content insets (to add margin from label text sizes) - used in goals total and streak counters
        let counterContentInsets = UIEdgeInsets.init(top: 3, left: 5, bottom: 3, right: 5)
    }
}
