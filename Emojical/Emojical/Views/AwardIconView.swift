//
//  AwardIconView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// Custom view to draw award icon (emoji + circle border around it)
class AwardIconView : ThemeObservingView {
    
    // MARK: - Inspectable public properties
    
    @IBInspectable
    var labelText: String? { didSet { configureViews() }}

    @IBInspectable
    var labelBackgroundColor: UIColor = UIColor.clear { didSet { configureViews() }}

    @IBInspectable
    var emojiFontSize: CGFloat = 24.0 { didSet { configureViews() }}

    @IBInspectable
    var borderColor: UIColor = UIColor.blue { didSet { configureViews() }}

    @IBInspectable
    var borderWidth: CGFloat = 2.0 { didSet { configureViews() }}

    // MARK: - Private state
    
    // Emoji label
    var labelView: UILabel!
    
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

        labelView = UILabel(frame: CGRect.zero)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center

        addSubview(labelView)

        labelView.clipsToBounds = true
        labelView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        labelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        labelView.widthAnchor.constraint(equalTo: labelView.heightAnchor).isActive = true
    }
    
    func configureViews() {
        labelView.font = UIFont.systemFont(ofSize: emojiFontSize)
        labelView.backgroundColor = labelBackgroundColor
        labelView.text = labelText
        labelView.layer.borderWidth = borderWidth
        labelView.layer.borderColor = borderColor.cgColor
        
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }

    // Since CGColor is not dynamic,
    // need to update layer border color when appearance changed
    override func updateColors() {
        labelView.layer.borderColor = borderColor.cgColor
    }
    
    private func setupConstraints() {
        labelView.layer.cornerRadius = bounds.maxX / 2.0
        if labelViewSize == nil {
            labelViewSize = labelView.widthAnchor.constraint(equalToConstant: bounds.maxX)
        } else {
            labelViewSize?.constant = bounds.maxX
        }
        labelViewSize?.isActive = true
    }
}
