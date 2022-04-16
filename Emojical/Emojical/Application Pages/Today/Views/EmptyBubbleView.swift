//
//  EmptyBubbleView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 04/16/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import UIKit

class EmptyBubbleView : ThemeObservingView {

    // MARK: - UI Outlets
    
    /// Smiley face on top of the RecapBubble (exact artwork will depend on how good recap is)
    @IBOutlet weak var face: UIImageView!

    /// Speach bubble background view
    @IBOutlet weak var bubble: UIView!
    
    /// Text label to display recap text
    @IBOutlet weak var text: UILabel!
    
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

    func loadData(_ data: EmptyWeekBubbleData) {
        text.text = data.message
        faceImage = data.faceImage.resized(to: face.bounds.size)
        face.image = faceImage
            .stroked(with: Theme.main.colors.background,
                     width: Specs.emojiStrokeThickness)
    }
    
    // MARK: - Private helpers
    
    private func setupViews() {
        backgroundColor = UIColor.clear
        text.font = Theme.main.fonts.listBody
        bubble.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.2)
        bubble.layer.cornerRadius = Specs.textBubbleRadius

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        onTapped?()
    }
    
    // Since stroked image is generated in run-time - we need to refresh it
    // if dark/light theme is changed
    override func updateColors() {
        guard faceImage != nil else { return }
        
        face.image = faceImage.stroked(
            with: Theme.main.colors.background,
            width: Specs.emojiStrokeThickness
        )
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Bubble corner radius
    static let textBubbleRadius: CGFloat = 15.0
    
    /// Stroke around face emoji thickness
    static let emojiStrokeThickness: CGFloat = 5.0
}
