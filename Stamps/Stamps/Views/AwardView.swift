//
//  AwardView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

// Custom view that draws a star with circle around it. Cirle optionally can be broken
// into several arcs - for monthly awards we use full circle, for weekly - 7-arches circle. 
class AwardView : UIView {
    
    private var color: UIColor = UIColor.blue
    private var dashes: Int = 7
    private var spacing: Double = 0.7
    
    private let borderThickness: CGFloat = 0.07
    private let starRatio: CGFloat = 0.78
    
    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(color: UIColor, dashes: Int) {
        self.color = color
        self.dashes = dashes
        setupView()
    }

    private func setupView() {
        let size = bounds.width
        layer.sublayers?.removeAll()
        layer.cornerRadius = size / 2.0
        clipsToBounds = true
        
        let border = CAShapeLayer()
        border.strokeColor = color.cgColor
        border.lineWidth = size * borderThickness * 2.0
        
        if dashes > 0 {
            let dashLength = Double(bounds.width) * Double.pi / Double(dashes)
            border.lineDashPattern = [NSNumber(value: dashLength * spacing), NSNumber(value: dashLength * (1 - spacing))]
            border.lineDashPhase = CGFloat(dashLength * spacing / 2)
        }
        
        border.frame = bounds
        border.fillColor = backgroundColor?.cgColor
        border.path = UIBezierPath(roundedRect: bounds, cornerRadius: size / 2.0).cgPath
        layer.addSublayer(border)
        
        let star = CAShapeLayer()
        let offset = size * (1 - starRatio) / 2
        star.path = starPath(size: size * starRatio, offset: CGPoint(x: offset, y: offset)).cgPath
        star.fillColor = color.cgColor
        
        layer.addSublayer(star)
    }
    
    func starPath(size: CGFloat, offset: CGPoint) -> UIBezierPath {
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 0.51 * size + offset.x, y: offset.y))
        starPath.addLine(to: CGPoint(x: 0.66 * size + offset.x, y: 0.30 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.99 * size + offset.x, y: 0.35 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.75 * size + offset.x, y: 0.58 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.80 * size + offset.x, y: 0.90 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.51 * size + offset.x, y: 0.75 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.22 * size + offset.x, y: 0.90 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.27 * size + offset.x, y: 0.58 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.03 * size + offset.x, y: 0.35 * size + offset.y))
        starPath.addLine(to: CGPoint(x: 0.36 * size + offset.x, y: 0.30 * size + offset.y))
        starPath.close()
        return starPath
    }
}
