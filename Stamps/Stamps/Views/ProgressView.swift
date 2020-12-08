//
//  WeekBadgeView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class ProgressView : UIView {
    
    @IBInspectable
    var baseColor: UIColor = UIColor.lightGray

    @IBInspectable
    var progress: CGFloat = 0.5

    @IBInspectable
    var lineWidth: CGFloat = 5.0

    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        //// Variable Declarations
        let resultAngle: CGFloat = -1 * progress * 360 + 90

        let barRect = rect.insetBy(dx: lineWidth, dy: lineWidth)
        
        //// baseBar Drawing
        let baseBarPath = UIBezierPath(ovalIn: barRect)
        baseColor.withAlphaComponent(0.3).setStroke()
        baseBarPath.lineWidth = lineWidth
        baseBarPath.stroke()

        //// progressBar Drawing
        let progressBarPath = UIBezierPath()
        progressBarPath.addArc(withCenter: CGPoint(x: barRect.midX, y: barRect.midY), radius: barRect.width / 2, startAngle: -90 * CGFloat.pi/180, endAngle: -resultAngle * CGFloat.pi/180, clockwise: true)

        tintColor.setStroke()
        progressBarPath.lineWidth = lineWidth
        progressBarPath.lineCapStyle = .round
        progressBarPath.lineJoinStyle = .round
        progressBarPath.stroke()
    }
}
