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
    var progressColor: UIColor = Theme.main.colors.tint { didSet { setupView() }}

    @IBInspectable
    var clockwise: Bool = true { didSet { setupView() }}

    @IBInspectable
    var labelColor: UIColor = UIColor.clear { didSet { setupView() }}
    
    @IBInspectable
    var progress: CGFloat = 0.5 { didSet { setupView() }}

    @IBInspectable
    var emojiFontSize: CGFloat = 24.0 { didSet { setupView() }}

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
        
        let barRect = bounds.insetBy(dx: progressLineWidth / 2.0, dy: progressLineWidth / 2.0)
        let radius = barRect.height / 2.0

        let label = UILabel(frame: barRect)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: emojiFontSize)
        label.textAlignment = .center
        label.backgroundColor = labelColor
        label.text = text
        label.layer.cornerRadius = radius
        label.clipsToBounds = true
        addSubview(label)
        self.labelView = label

        // Add progress bar layer
        let progressPath = UIBezierPath()
        let resultAngle: CGFloat = -90 + (clockwise ? 1 : -1) * (progress * 360)
        let border = CAShapeLayer()

        border.strokeColor = progressColor.cgColor
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = progressLineWidth
        border.frame = bounds
        border.lineCap = .round
        progressPath.addArc(
            withCenter: CGPoint(x: barRect.midX, y: barRect.midY),
            radius: radius,
            startAngle: -90 * CGFloat.pi / 180,
            endAngle: resultAngle * CGFloat.pi / 180,
            clockwise: clockwise
        )

        border.path = progressPath.cgPath
        layer.addSublayer(border)
    }
}
