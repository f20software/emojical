//
//  RecapBubbleView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 04/10/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import UIKit


extension UIView {

    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true

    }
}

class RecapBubbleView : ThemeObservingView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var face: UIImageView!
    @IBOutlet weak var bubble: UIView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var awards: UIStackView!
    @IBOutlet weak var chevron: UIImageView!

    // MARK: - Private references
    
    private var tapRecognizer: UITapGestureRecognizer?
    
    // Storing original image, so we can create stroked version dynamically if
    // dark/light mode is changed
    private var faceImage: UIImage!

    // MARK: - Callbacks
    
    // Called when user tapped on the award cell
    var onTapped: (() -> Void)?

    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface

    func loadData(_ data: RecapBubbleData) {
        text.text = data.message
        faceImage = data.faceImage.resized(to: face.bounds.size)
        
        face.image = faceImage
            .stroked(with: Theme.main.colors.background,
                     width: Specs.emojiStrokeThickness)
        
        awards.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard data.icons.count > 0 else { return }
        
        data.icons.forEach { award in
            guard award.reached else { return }
            
            let b = UIView(frame: .zero)
            b.heightAnchor.constraint(equalToConstant: 40).isActive = true
            b.widthAnchor.constraint(equalToConstant: 40).isActive = true
            b.backgroundColor = Theme.main.colors.background
            b.layer.cornerRadius = 20

            let a = AwardIconView(frame: CGRect.zero)
            a.labelText = award.emoji
            a.emojiFontSize = 14
            a.labelBackgroundColor = award.backgroundColor
            a.borderColor = award.borderColor
            a.borderWidth = Theme.main.specs.progressWidthSmall
            
            b.addSubview(a)
            a.bindFrameToSuperviewBounds()
            awards.addArrangedSubview(b)
        }

        let a4 = UIView(frame: CGRect.zero)
        a4.heightAnchor.constraint(equalToConstant: 40).isActive = true
        a4.widthAnchor.constraint(equalToConstant: 40).isActive = true
        a4.backgroundColor = UIColor.clear
        awards.addArrangedSubview(a4)
        
        let spacing = ((awards.frame.width - 5) / CGFloat(data.icons.count)) - 40
        if spacing > 5 {
            awards.spacing = 5
        } else {
            awards.spacing = -10
        }
        awards.translatesAutoresizingMaskIntoConstraints = false
        awards.backgroundColor = UIColor.clear
    }
    
    // MARK: - Private helpers
    
    private func setupViews() {
        text.font = Theme.main.fonts.listBody
        bubble.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.2)
        bubble.layer.cornerRadius = Specs.textBubbleRadius
        backgroundColor = UIColor.clear

        chevron.image = Specs.chevronImage
        chevron.tintColor = Theme.main.colors.tint
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        onTapped?()
    }
    
    override func updateColors() {
        face.image = faceImage.stroked(
            with: Theme.main.colors.background,
            width: Specs.emojiStrokeThickness
        )
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Award cell size
    static let awardSize: CGFloat = 55.0
    
    /// Margin around award icons
    static let awardMargin: CGFloat = 3.0
    
    /// Margin before first award icon
    static let awardsLeadingMargin: CGFloat = 16.0
    
    /// Margin from the left/right of the award strip
    static let awardStripHorizontalMargin: CGFloat = 5.0

    /// Bubble corner radius
    static let textBubbleRadius: CGFloat = 15.0
    
    /// Stroke around face emoji thickness
    static let emojiStrokeThickness: CGFloat = 10.0
    
    /// Image for > chevron - so we have build-time validation
    static let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))
}
