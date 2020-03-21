//
//  MonthBadgeView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MonthBadgeView : UIView {
    
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

        let size = Double(rect.height) // this will be badge circle diameter
        for i in 0..<badges.count {
            let starPath = getStar(size: CGFloat(size), offset: CGFloat((size + padding) * Double(i)))
            UIColor.clear.setFill()
            badges[i].set()
            starPath.fill()
        }
    }
    
    func getStar(size: CGFloat, offset: CGFloat) -> UIBezierPath {
        
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 0.51 * size + offset, y: 0))
        starPath.addLine(to: CGPoint(x: 0.66 * size + offset, y: 0.30 * size))
        starPath.addLine(to: CGPoint(x: 0.99 * size + offset, y: 0.35 * size))
        starPath.addLine(to: CGPoint(x: 0.75 * size + offset, y: 0.58 * size))
        starPath.addLine(to: CGPoint(x: 0.80 * size + offset, y: 0.90 * size))
        starPath.addLine(to: CGPoint(x: 0.51 * size + offset, y: 0.75 * size))
        starPath.addLine(to: CGPoint(x: 0.22 * size + offset, y: 0.90 * size))
        starPath.addLine(to: CGPoint(x: 0.27 * size + offset, y: 0.58 * size))
        starPath.addLine(to: CGPoint(x: 0.03 * size + offset, y: 0.35 * size))
        starPath.addLine(to: CGPoint(x: 0.36 * size + offset, y: 0.30 * size))
        starPath.close()

        return starPath
    }
}
