//
//  StickerView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/26/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// Custom view to draw goal with progress or reached award (when progress is 100%)
class StickerView : UIView {
    
    // MARK: - Inspectable public properties
    
    @IBInspectable
    var color: UIColor = UIColor.clear { didSet { configureViews() }}
    
    @IBInspectable
    var emojiSizeRatio = Specs.emojiSizeRatio { didSet { configureViews() }}

    @IBInspectable
    var cornerRadius = Specs.cornerRadius { didSet { configureViews() }}

    @IBInspectable
    var borderWidth = Specs.borderWidth { didSet { configureViews() }}

    @IBInspectable
    var text: String? { didSet { configureViews() }}
    
    // MARK: - Private state
    
    // Emoji label
    private var labelView: UILabel?
    
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
        labelView?.font = UIFont.systemFont(ofSize: bounds.width * emojiSizeRatio)
        labelView?.backgroundColor = color.withAlphaComponent(0.25)
        labelView?.text = text
        labelView?.layer.cornerRadius = cornerRadius
        labelView?.layer.borderWidth = borderWidth
        labelView?.layer.borderColor = color.cgColor
    }
    
    // Initial view setup - just layout, no input parameters
    // Adding subview to render emoji
    private func setupView() {
        backgroundColor = UIColor.clear
        
        let label = UILabel(frame: bounds)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.clipsToBounds = true
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        self.labelView = label
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
