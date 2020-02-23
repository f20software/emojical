//
//  AwardBadgeView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class AwardBadgeView : UIView {
    
    // Array of colors for badges to be drawn
    var badges: [UIColor]?
    
    let padding = 5.0
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

        let size = Double(rect.width) // this will be badge circle diameter

        // Center all badges
        // First try to calculate margin if we use default padding between them
        var currentPadding = padding
        var topMargin = (Double(rect.height) - (size + padding) * Double(badges.count)) / 2 + padding / 2
        
        // If margin appear smaller then default one - decrease padding so badges will be sqwished together
        if topMargin < margin {
            topMargin = margin
            currentPadding = (Double(rect.height) - (size * Double(badges.count)) - margin * 2) / (Double(badges.count) - 1)
        }
        
        for i in 0..<badges.count {
            let starPath = getStar(size: CGFloat(size), offset: CGFloat(topMargin + (size + currentPadding) * Double(i)))
            UIColor.clear.setFill()
            badges[i].set()
            starPath.fill()
        }
    }
    
    func getStar(size: CGFloat, offset: CGFloat) -> UIBezierPath {
        
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 0.51 * size, y: offset))
        starPath.addLine(to: CGPoint(x: 0.66 * size, y: 0.30 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.99 * size, y: 0.35 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.75 * size, y: 0.58 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.80 * size, y: 0.90 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.51 * size, y: 0.75 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.22 * size, y: 0.90 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.27 * size, y: 0.58 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.03 * size, y: 0.35 * size + offset))
        starPath.addLine(to: CGPoint(x: 0.36 * size, y: 0.30 * size + offset))
        starPath.close()

        return starPath
    }
}
