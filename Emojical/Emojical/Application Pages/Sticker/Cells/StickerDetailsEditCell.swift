//
//  StickerDetailsEditCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerDetailsEditCell: ThemeObservingCollectionCell, StickerDetailEditViewProtocol {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var previewPlate: UIView!
    @IBOutlet weak var stickerBackground: UIView!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var separator1: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var separator3: UIView!
    @IBOutlet weak var separator4: UIView!

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emojiField: EmojiTextField!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var color0: UIView!
    @IBOutlet var color1: UIView!
    @IBOutlet var color2: UIView!
    @IBOutlet var color3: UIView!
    @IBOutlet var color4: UIView!
    @IBOutlet var color5: UIView!
    @IBOutlet var color6: UIView!
    @IBOutlet var customColor: GradientView!

    // MARK: - State
    
    /// Save off references to all color views for easy access
    private var allColorViews: [UIView]!

    /// Currently selected color view
    private var selectedColorIndex: Int = -1
    
    /// Last color view will be used for custom color configuration
    private let customColorIndex = 7

    // MARK: - View lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    // MARK: - StickerDetailsEditViewProtocol implementation
    
    /// Currently selected color
    var selectedColor: UIColor {
        guard selectedColorIndex >= 0 && selectedColorIndex < allColorViews.count else {
            return Theme.main.colors.tint
        }
        return allColorViews[selectedColorIndex].backgroundColor!
    }

    /// Sticker name value
    var name: String? { return nameField.text }
    
    /// Sticker emoji value
    var emoji: String? { return emojiField.text }

    /// User changed any value
    var onValueChanged: (() -> Void)?

    /// User tapped on list of stickers
    var onColorSelected: ((Int) -> Void)?

    /// User tapped on last color selection
    var onCustomColorTapped: (() -> Void)?

    // MARK: - Public view interface

    func configure(for data: StickerEditData) {
        nameField.text = data.sticker.name
        emojiField.text = data.sticker.label
        sticker.text = data.sticker.label
        sticker.color = data.sticker.color

        if let index = allColorViews.firstIndex(where: {
            $0.backgroundColor?.hex == data.sticker.color.hex }) {
            setSelectedColorIndex(index)
        } else {
            setCustomColor(data.sticker.color)
        }
    }
    
    /// Set emoji field to first responder and bring the keyboard up
    func focusOnEmojiField() {
        emojiField.becomeFirstResponder()
    }
    
    /// Update preview icon
    func updatePreview(label: String, color: UIColor) {
        sticker.color = color
        sticker.text = label
        sticker.setNeedsDisplay()
    }

    /// Sets custom color value
    func setCustomColor(_ color: UIColor) {
        setSelectedColorIndex(customColorIndex)
        customColor.customColor = color
        onValueChanged?()
    }

    /// Sets color palette (7 built-in colors)
    func setPaletteColors(_ colors: [UIColor]) {
        guard colors.count == 7 else { return }
        for i in 0..<colors.count {
            allColorViews[i].backgroundColor = colors[i]
        }
    }

    // MARK: - Private helpers

    private func setSelectedColorIndex(_ index: Int) {
        // Clear previous value
        if selectedColorIndex >= 0 && selectedColorIndex < allColorViews.count {
            allColorViews[selectedColorIndex].layer.borderWidth = 0.0
        }
     
        allColorViews[index].layer.borderWidth = Specs.colorsBorderWidth
        selectedColorIndex = index
    }

    private func configureViews() {
        plate.backgroundColor = UIColor.clear

        allColorViews = [color0, color1, color2, color3, color4, color5, color6, customColor]
        // Round corners will not be visible anywhere but on today's day
        for view in allColorViews {
            view.layer.cornerRadius = Specs.colorsCornerRadius
            view.clipsToBounds = true
            view.backgroundColor = Theme.main.colors.background
            view.layer.borderColor = Theme.main.colors.text.cgColor
            view.layer.borderWidth = 0.0
        }
        
        let labels: [UILabel] = [nameLabel, emojiLabel, previewLabel]
        for label in labels {
            label.font = Theme.main.fonts.formFieldCaption
            label.textColor = Theme.main.colors.secondaryText
        }

        nameLabel.text = "name_label".localized
        nameField.backgroundColor = Theme.main.colors.secondaryBackground
        nameField.font = Theme.main.fonts.listBody
        nameField.placeholder = "sticker_name_placeholder".localized
        separator1.backgroundColor = Theme.main.colors.separator

        emojiLabel.text = "emoji_label".localized
        emojiField.backgroundColor = Theme.main.colors.secondaryBackground
        emojiField.font = Theme.main.fonts.listBody
        emojiField.delegate = self
        emojiField.placeholder = ""
        separator2.backgroundColor = Theme.main.colors.separator

        previewLabel.text = "preview_label".localized
        previewPlate.backgroundColor = Theme.main.colors.secondaryBackground
        previewPlate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        previewPlate.clipsToBounds = true
        separator3.backgroundColor = Theme.main.colors.separator

        stickerBackground.backgroundColor = Theme.main.colors.background
        stickerBackground.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        separator4.backgroundColor = Theme.main.colors.separator
    }
    
    override func updateColors() {
        allColorViews = [color0, color1, color2, color3, color4, color5, color6, customColor]
        for view in allColorViews {
            view.layer.borderColor = Theme.main.colors.text.cgColor
        }
    }
    
    @IBAction func textChanged(_ sender: Any) {
        onValueChanged?()
    }

    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: stackView)
        guard stackView.bounds.contains(loc) else { return }
        
        let index = Int(ceil(loc.x / (stackView.frame.width / 8))) - 1
        
        if index >= 0 && index < 7 {
            setSelectedColorIndex(index)
            onColorSelected?(index)
        } else if index == customColorIndex {
            onCustomColorTapped?()
        }
    }
}

extension StickerDetailsEditCell: UITextFieldDelegate {

    // Limit emoji text field to a single character
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let character = string.first {
            textField.text = String(character)
        } else {
            textField.text = ""
        }
        onValueChanged?()
        return false
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Color selector corner radius
    static let colorsCornerRadius: CGFloat = 10.0
    
    /// Color selector thikness
    static let colorsBorderWidth: CGFloat = 3.0
}

