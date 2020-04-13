//
//  DayBadgeView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayBadgeView : UIView {
    
    // Array of colors for badges to be drawn
    var badges: [UIColor]?
    
    let padding = 3.0
    let margin = 8.0
    
    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let badges = badges else {
            return
        }

        let size = Double(rect.height) // this will be badge circle diameter

        // Center all badges
        // First try to calculate margin if we use default padding between them
        var currentPadding = padding
        var leftMargin = (Double(rect.width) - (size + padding) * Double(badges.count)) / 2 + padding / 2
        
        // If margin appear smaller then default one - decrease padding so badges will be sqwished together
        if leftMargin < margin {
            leftMargin = margin
            currentPadding = (Double(rect.width) - (size * Double(badges.count)) - margin * 2) / (Double(badges.count) - 1)
        }
        
        for i in 0..<badges.count {
            let badgeRect = CGRect(x: leftMargin + (size + currentPadding) * Double(i), y: 0, width: size, height: size)
            let bpath = UIBezierPath(ovalIn: badgeRect)
            UIColor.clear.setFill()
            badges[i].set()
            bpath.fill()
        }
    }
}
