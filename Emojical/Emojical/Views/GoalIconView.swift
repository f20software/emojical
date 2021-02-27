//
//  GoalIconView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// Custom view to draw goal with progress
class GoalIconView : ThemeObservingView {
    
    // MARK: - Inspectable public properties
    
    @IBInspectable
    var labelText: String? { didSet { configureViews() }}

    @IBInspectable
    var labelBackgroundColor: UIColor = UIColor.clear { didSet { configureViews() }}

    @IBInspectable
    var emojiFontSize: CGFloat = 24.0 { didSet { configureViews() }}

    @IBInspectable
    var clockwise: Bool = true { didSet { configureViews() }}

    @IBInspectable
    var progress: CGFloat = 0.5 { didSet { configureViews() }}

    @IBInspectable
    var progressColor: UIColor = UIColor.blue { didSet { configureViews() }}

    @IBInspectable
    var progressLineWidth: CGFloat = 2.0 { didSet { configureViews() }}

    @IBInspectable
    var progressLineGap: CGFloat = 1.0 { didSet { configureViews() }}

    // MARK: - Private state
    
    // Emoji label
    var labelView: UILabel!
    
    // Shape layer to display progress indicator
    var circleLayer: CAShapeLayer!
    
    // Size constraint
    var labelViewSize: NSLayoutConstraint?

    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = UIColor.clear

        circleLayer = CAShapeLayer()
        circleLayer.fillColor = UIColor.clear.cgColor
        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0
        circleLayer.lineCap = .round

        labelView = UILabel(frame: CGRect.zero)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center

        addSubview(labelView)
        layer.addSublayer(circleLayer)

        labelView.clipsToBounds = true
        labelView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        labelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        labelView.widthAnchor.constraint(equalTo: labelView.heightAnchor).isActive = true
    }
    
    func configureViews() {
        circleLayer.lineWidth = progressLineWidth
        circleLayer.strokeColor = progressColor.cgColor
        circleLayer.strokeEnd = progress
        
        labelView.font = UIFont.systemFont(ofSize: emojiFontSize)
        labelView.backgroundColor = labelBackgroundColor
        labelView.text = labelText
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }

    // Since CGColor is not dynamic,
    // need to update layer border color when appearance changed
    override func updateColors() {
        circleLayer.strokeColor = progressColor.cgColor
    }

    private func setupConstraints() {

        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let startAngle = -90 * CGFloat.pi / 180
        let endAngle = (-90 + (clockwise ? 1 : -1) * 360) * CGFloat.pi / 180

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: CGFloat(bounds.maxX - progressLineWidth) / 2,
            startAngle: startAngle, // -CGFloat(Double.pi * 0.5),
            endAngle: endAngle, // CGFloat(Double.pi * 1.5),
            clockwise: clockwise)
        circleLayer.path = circlePath.cgPath
        
        let labelGap = progressLineWidth + progressLineGap
        let labelSize = bounds.maxX - (labelGap * 2)
        
        labelView.layer.cornerRadius = labelSize / 2.0
        if labelViewSize == nil {
            labelViewSize = labelView.widthAnchor.constraint(equalToConstant: labelSize)
        } else {
            labelViewSize?.constant = labelSize
        }
        labelViewSize?.isActive = true
    }

    
    func animateProgress(to value: CGFloat, duration: TimeInterval, completion: @escaping (() -> Void)) {
        // We want to animate the strokeEnd property of the circleLayer
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // Set the animation duration appropriately
        animation.duration = duration

        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = progress
        animation.toValue = value

        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = value

        // Do the actual animation
        CATransaction.setCompletionBlock(completion)
        circleLayer.add(animation, forKey: "animateCircle")
        CATransaction.commit()
    }
}
