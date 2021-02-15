//
//  GradientView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// Custom view to draw horizontal rectangular gradient - either from white to black or full RGB color spectr
class GradientView : UIView {
    
    // MARK: - Inspectable public properties
    
    @IBInspectable
    var customColor: UIColor? = nil { didSet { configureViews() }}
    
    // MARK: - Private state
    
    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureViews()
    }

    // MARK: - Private helpers
    
    // Configure text and color and other parameters for the emoji subview
    private func configureViews() {

        // Custom color set? No need to configure gradient
        if customColor != nil {
            layer.sublayers = nil
            backgroundColor = customColor!
            return
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.type = .conic
        gradient.colors = [
            UIColor.red.cgColor,
            UIColor.yellow.cgColor,
            UIColor.green.cgColor,
            UIColor.cyan.cgColor,
            UIColor.blue.cgColor,
            UIColor.magenta.cgColor,
            UIColor.red.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.75)

        layer.sublayers = nil
        layer.insertSublayer(gradient, at: 0)
    }
    
    // Initial view setup - just layout, no input parameters
    private func setupView() {
        configureViews()
    }
}

// MARK: - Specs

fileprivate struct Specs {
    
    /// Default ratio for Emoji font size to the view width
    static let emojiSizeRatio: CGFloat = 0.5

    /// Default corner radius
    static let cornerRadius: CGFloat = 8.0
    
    /// Default border width
    static let borderWidth: CGFloat = 2.0
}
