//
//  StickerView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/26/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

enum StickerStyle: Int {

    /// Default sticker style with 0.25 opacity and a border
    case `default` = 0
    
    /// Borderless style sticker - 0.5 opacity
    case borderless = 1
}

/// Custom view to draw goal with progress or reached award (when progress is 100%)
class StickerView : UIView {
    
    // MARK: - Inspectable public properties
    
    @IBInspectable
    var color: UIColor = UIColor.clear { didSet { configureViews() }}
    
    @IBInspectable
    var emojiSizeRatio = 1.0 { didSet { configureViews() }}

    @IBInspectable
    var cornerRadius = 0.0 { didSet { configureViews() }}

    @IBInspectable
    var borderWidth = 0.0 { didSet { configureViews() }}

    @IBInspectable
    var text: String? { didSet { configureViews() }}

    /// Sticker style
    /// TODO: Potentially can be done via proper DI, but for now we can stick with global setting
    var style: StickerStyle = LocalSettings.shared.stickerStyle
    
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
        labelView?.font = UIFont.systemFont(ofSize: bounds.width * Specs[style]!.emojiSizeRatio)
        labelView?.backgroundColor = color.withAlphaComponent(Specs[style]!.opacity)
        labelView?.text = text
        labelView?.layer.cornerRadius = Specs[style]!.cornerRadius
        labelView?.layer.borderWidth = Specs[style]!.borderWidth
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

fileprivate struct StickerSpecs {
    /// Background opacity
    let opacity: CGFloat
    
    /// Default ratio for Emoji font size to the view width
    let emojiSizeRatio: CGFloat

    /// Default corner radius
    let cornerRadius: CGFloat
    
    /// Default border width
    let borderWidth: CGFloat
}

fileprivate let Specs: [StickerStyle: StickerSpecs] = [
    .default: StickerSpecs(
        opacity: 0.25,
        emojiSizeRatio: 0.55,
        cornerRadius: 8.0,
        borderWidth: 2.0
    ),
    .borderless: StickerSpecs(
        opacity: 0.4,
        emojiSizeRatio: 0.6,
        cornerRadius: 5.0,
        borderWidth: 0.0
    )
]
