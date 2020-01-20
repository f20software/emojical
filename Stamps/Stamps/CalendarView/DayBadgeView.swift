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
    
    //initWithFrame to init view from code
    override init(frame: CGRect) {
      super.init(frame: frame)
      // setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      // setupView()
    }
    
    override func draw(_ rect: CGRect) {
        guard let badges = badges else {
            return
        }

        let size = Double(rect.height)
        // Center all badges
        let leftMargin = (Double(rect.width) - (size + padding) * Double(badges.count)) / 2 + padding / 2 
        for i in 0..<badges.count {
            let badgeRect = CGRect(x: leftMargin + (size + padding) * Double(i), y: 0, width: size, height: size)
            let bpath = UIBezierPath(ovalIn: badgeRect)
            UIColor.clear.setFill()
            badges[i].set()
            bpath.fill()
            
//            UIColor.white.setStroke()
//            bpath.stroke()
        }
    }
}
