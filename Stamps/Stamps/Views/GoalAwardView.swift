//
//  GoalAwardView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// Custom view to draw goal with progress or reached award (when progress is 100%)
class GoalAwardView : UIView {
    
    // MARK: - Inspectable public properties
    
    @IBInspectable
    var progressColor: UIColor = UIColor.appTintColor { didSet { setupView() }}

    @IBInspectable
    var labelColor: UIColor = UIColor.clear { didSet { setupView() }}
    
    @IBInspectable
    var progress: CGFloat = 0.5 { didSet { setupView() }}

    @IBInspectable
    var progressLineWidth: CGFloat = 2.0 { didSet { setupView() }}

    @IBInspectable
    var text: String? { didSet { setupView() }}
    
    // MARK: - Private state
    
    // Emoji label
    var labelView: UILabel?
    
    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(text: String?, progress: CGFloat) {
        self.text = text
        self.progress = progress
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    private func setupView() {
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.removeAll()

        let size = bounds.width
        
        // Base layer - make it cirlce
        layer.cornerRadius = size / 2.0
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        let labelRect = bounds.insetBy(dx: progressLineWidth / 2, dy: progressLineWidth / 2)
        let label = UILabel(frame: labelRect)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.backgroundColor = labelColor
        label.text = text
        label.layer.cornerRadius = labelRect.height / 2.0
        label.clipsToBounds = true
        addSubview(label)
        self.labelView = label

        // Add progress bar layer
        let barRect = bounds.insetBy(dx: progressLineWidth / 2, dy: progressLineWidth / 2)
        let progressPath = UIBezierPath()
        let resultAngle: CGFloat = -1 * progress * 360 + 90
        let border = CAShapeLayer()

        border.strokeColor = progressColor.cgColor
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = progressLineWidth
        border.frame = bounds
        border.lineCap = .round
        progressPath.addArc(withCenter: CGPoint(x: barRect.midX, y: barRect.midY), radius: barRect.width / 2, startAngle: -90 * CGFloat.pi/180, endAngle: -resultAngle * CGFloat.pi/180, clockwise: true)
        border.path = progressPath.cgPath
        layer.addSublayer(border)
    }
}
