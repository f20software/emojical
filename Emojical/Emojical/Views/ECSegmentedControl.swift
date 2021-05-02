//
//  ECSegementedControl.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 8/29/20.
//  Copyright © 2020 Feed Me LLC. All rights reserved.
//

import UIKit

/// Corner style for the selector view
enum CornerStyle {
    
    /// Half circle rounded corners
    case halfHeight
    
    /// Exact value to be applied to cornerRadius
    case value(CGFloat)
}

@IBDesignable
class ECSegmentedControl: UIControl {

    // MARK: - Public properties
    
    /// Index of selected button. When `selectedSegmentIndex` is `nil` - selector view is hidden
    var selectedSegmentIndex: Int? = nil {
        // Animate only when moving selector from a visible position
        didSet { moveSelector(animated: oldValue != nil) }
    }

    @IBInspectable
    var buttonTitles: String = "" {
        didSet { setTitles(to: buttonTitles.components(separatedBy: ",")) }
    }
    
    var buttonFont: UIFont = UIFont.boldSystemFont(ofSize: 16.0) {
        didSet { updateStyles() }
    }

    @IBInspectable
    var buttonTitleColor: UIColor = UIColor.red {
        didSet { updateStyles() }
    }
    
    @IBInspectable
    var buttonColors: [UIColor] = [UIColor.black] {
        didSet { updateSelection() }
    }

    @IBInspectable
    var buttonSelectedTitleColor: UIColor = UIColor.white {
        didSet { updateSelection() }
    }
    
    // MARK: - Private style (depend of the device size class)
    
    private var style: Style = Specs.full
    
    // MARK: - Private state
    
    /// Array of buttons
    private var buttons = [UIButton]()

    /// Stack view to hold buttons
    private var stackView: UIStackView!

    /// Selector view on top of the buttons to mark selected
    private var selector: UIView!

    /// Leading constraint for selector view - will be set to match leading position of selected button
    private var selectorLeading: NSLayoutConstraint!
    
    /// Width constraint for selector view - will be set to match width of selected button
    private var selectorWidth: NSLayoutConstraint!

    /// Update title on buttons
    func setTitles(to titles: [String]) {
        // Some sanity check - if number of titles doesn't match buttons count - recreate views
        if titles.count != buttons.count {
            setupView(buttonsCount: titles.count)
        }

        for (idx, button) in buttons.enumerated() {
            button.setTitle(titles[idx], for: .normal)
        }

        layoutIfNeeded()
        updateSelection()
    }

    // MARK: - Private helpers

    /// Configure view layout and create necessary subviews
    private func setupView(buttonsCount: Int) {
        guard buttonsCount != buttons.count else { return }
        
        // Remove existing subviews if any
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }

        if traitCollection.horizontalSizeClass == .compact {
            style = Specs.compact
        } else {
            style = Specs.full
        }

        for _ in 0..<buttonsCount {
            let button = UIButton(type: .system)
            buttons.append(button)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        }

        // Position and color for selector will be setup once layout for buttons is complete
        selector = UIView(frame: CGRect.zero)
        addSubview(selector)

        // Selector view contstraints - top and bottom align to a superview
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selector.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        // Creating leading and width constraint that we later will assign values
        // according to the button selector should cover
        selectorLeading = selector.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        selectorLeading.isActive = true
        selectorLeading.constant = 0
        selectorWidth = selector.widthAnchor.constraint(equalToConstant: 0)
        selectorWidth.isActive = true
        selectorWidth.constant = 0

        // Container for the buttons
        stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = style.buttonSpacing
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        updateStyles()
    }

    /// Update styles on buttons and selector view
    private func updateStyles() {
        guard buttons.count > 0 else { return }

        stackView.spacing = style.buttonSpacing
        buttons.forEach {
            $0.setTitleColor(buttonTitleColor, for: .normal)
            $0.titleLabel?.font = buttonFont
            $0.contentEdgeInsets = style.textInsets
        }

        setNeedsLayout()
        updateSelection()
    }

    /// Configure selector view position to cover selected button
    private func updateSelection() {
        /// Sanity check for `selectedSegmentIndex`valid values
        guard let idx = selectedSegmentIndex,
              (0..<buttons.count).contains(idx) else {
            selector.isHidden = true
            return
        }

        selector.isHidden = false

        // Selected button color
        buttons[idx].setTitleColor(buttonSelectedTitleColor, for: .normal)

        // Selector position and width
        selectorWidth.constant = buttons[idx].bounds.width
        selectorLeading.constant = buttons[idx].frame.minX
        
        // Selector corner radius style and background color
        switch style.selectorStyle {
        case .halfHeight:
            selector.layer.cornerRadius = selector.bounds.height / 2.0
        case .value(let radius):
            selector.layer.cornerRadius = radius
        }
        selector.backgroundColor = buttonColors[idx % buttonColors.count]
    }
    
    /// Move selector to a new position
    private func moveSelector(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0, options: [.curveEaseInOut], animations:
            {
                self.updateSelection()
                self.layoutIfNeeded()
            })
        } else {
            updateSelection()
        }
    }
    
    // MARK: - Outlet for button tapped event
    
    @objc private func buttonTapped(button: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(buttonTitleColor, for: .normal)
            if btn == button {
                selectedSegmentIndex = buttonIndex
            }
        }
        sendActions(for: .valueChanged)
    }
}

// MARK: - Specs

fileprivate struct Style {
    /// Selector corner style
    let selectorStyle: CornerStyle
    
    /// Buttons text insets
    let textInsets: UIEdgeInsets
    
    /// Button spacing
    let buttonSpacing: CGFloat
}

fileprivate struct Specs {

    /// iPhone style
    static let compact = Style(
        selectorStyle: .value(5.0),
        textInsets: UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14),
        buttonSpacing: 5.0
    )
    
    /// iPad style
    static let full = Style(
        selectorStyle: .halfHeight,
        textInsets: UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20),
        buttonSpacing: 10.0
    )
}
