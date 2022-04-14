//
//  RecapBubbleView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 04/10/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import UIKit

class RecapBubbleView : ThemeObservingView {

    // MARK: - UI Outlets
    
    /// Smiley face on top of the RecapBubble (exact artwork will depend on how good recap is)
    @IBOutlet weak var face: UIImageView!

    /// Speach bubble background view
    @IBOutlet weak var bubble: UIView!
    
    /// Text label to display recap text
    @IBOutlet weak var text: UILabel!
    
    /// Disclosure chevron indicating tappability
    @IBOutlet weak var chevron: UIImageView!
    
    /// Background view to hold all award icons - icons will be created dynamically
    @IBOutlet weak var awards: UIView!
    
    /// Text label to bottom constraint. Used to hide awards strip when there are none
    @IBOutlet weak var textBottomConstraint: NSLayoutConstraint!

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
        // Remove all previously created award icons
        awards.subviews.forEach { $0.removeFromSuperview() }

        face.image = faceImage
            .stroked(with: Theme.main.colors.background,
                     width: Specs.emojiStrokeThickness)

        // Let the height of the awards view be diameter of the award icon
        let awardSize = awards.frame.height

        // Adjust constraint from the text to the bottom
        // It will hide awards line if there are none
        textBottomConstraint.constant = awardSize + Specs.awardMargin * 2
        guard data.icons.count > 0 else {
            textBottomConstraint.constant = Specs.awardMargin
            return
        }
        
        var spacing = (awards.frame.width / CGFloat(data.icons.count)) - awardSize
        if spacing > Specs.awardDefaultSpacing {
            // We have enough room to fill them all
            spacing = Specs.awardDefaultSpacing
        } else if spacing >= Specs.awardOverlapSpacing {
            // We don't have enough room and they might overlap a little - make it standard
            spacing = Specs.awardOverlapSpacing
        } else {
            // Calculated spacing < Specs.awardOverlapSpacing - too many icons
            // Just go with calculated
        }

        var offset: CGFloat = 0.0
        data.icons.forEach { award in

            // Create white circle behind the award icon, so we can do overlap
            // Note that award icon is semi-transparent
            let abv = createAwardBackgroundView(size: awardSize)
            let aiv = createAwardIconView(award: award)
            awards.addSubview(abv)
            awards.addSubview(aiv)

            // Both views would have same contraint - size and alignment to the superview
            [abv, aiv].forEach { view in
                view.widthAnchor.constraint(equalTo: awards.heightAnchor).isActive = true
                view.heightAnchor.constraint(equalTo: awards.heightAnchor).isActive = true
                view.topAnchor.constraint(equalTo: awards.topAnchor).isActive = true
                view.leadingAnchor.constraint(equalTo: awards.leadingAnchor, constant: offset).isActive = true
            }
            
            offset = offset + awardSize + spacing
        }
    }
    
    // MARK: - Private helpers
    
    // Wrapper to create circle background view for award icon
    private func createAwardBackgroundView(size: CGFloat) -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.main.colors.background
        view.layer.cornerRadius = size / 2.0
        return view
    }
    
    // Wrapper to create award icon view
    private func createAwardIconView(award: AwardIconData) -> AwardIconView {
        let view = AwardIconView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.labelText = award.emoji
        view.emojiFontSize = Specs.awardEmojiFontSize
        view.labelBackgroundColor = award.backgroundColor
        view.borderColor = award.borderColor
        view.borderWidth = Theme.main.specs.progressWidthSmall
        return view
    }
    
    private func setupViews() {
        backgroundColor = UIColor.clear
        awards.backgroundColor = UIColor.clear
        text.font = Theme.main.fonts.listBody
        bubble.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.2)
        bubble.layer.cornerRadius = Specs.textBubbleRadius
        chevron.image = Specs.chevronImage
        chevron.tintColor = Theme.main.colors.tint

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        onTapped?()
    }
    
    // Since stroked image is generated in run-time - we need to refresh it
    // if dark/light theme is changed
    override func updateColors() {
        face.image = faceImage.stroked(
            with: Theme.main.colors.background,
            width: Specs.emojiStrokeThickness
        )
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Default spacing between award icons (if we have room)
    static let awardDefaultSpacing: CGFloat = 5.0

    /// Default overlap between award icons (if we don't have enough room to fit them all)
    static let awardOverlapSpacing: CGFloat = -10.0

    /// Margin from top and bottom to list of awards
    static let awardMargin: CGFloat = 15.0
    
    /// Bubble corner radius
    static let textBubbleRadius: CGFloat = 15.0
    
    /// Stroke around face emoji thickness
    static let emojiStrokeThickness: CGFloat = 5.0
    
    /// Size of the font for the award emoji
    static let awardEmojiFontSize: CGFloat = 14.0
    
    /// Image for > chevron - so we have build-time validation
    static let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))
}
