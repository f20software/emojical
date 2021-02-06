//
//  StickerDetailsEditCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerDetailsEditCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var stickerIcon: StickerView!
    @IBOutlet weak var previewPlate: UIView!
    @IBOutlet weak var stickerBackground: UIView!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var separator1: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var separator3: UIView!

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emoji: EmojiTextField!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var name: UITextField!

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var color0: UIView!
    @IBOutlet var color1: UIView!
    @IBOutlet var color2: UIView!
    @IBOutlet var color3: UIView!
    @IBOutlet var color4: UIView!
    @IBOutlet var color5: UIView!
    @IBOutlet var color6: UIView!

    // MARK: - State
    
    var selectedColorIndex = -1
    var allColorViews: [UIView]!

    /// User changed any value
    var onValueChanged: (() -> Void)?

    /// User tapped on list of stickers
    var onColorSelected: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Public view interface

    func configure(for data: StickerEditData) {
        name.text = data.sticker.name
        emoji.text = data.sticker.label
        stickerIcon.text = data.sticker.label
        stickerIcon.color = data.sticker.color

        if let index = allColorViews.firstIndex(where: { $0.backgroundColor?.hex == data.sticker.color.hex }) {
            setSelectedColorIndex(index)
        }
    }
    
    // MARK: - Private helpers

    func setSelectedColorIndex(_ index: Int) {
        // Clear previous value
        if selectedColorIndex >= 0 {
            allColorViews[selectedColorIndex].layer.borderWidth = 0.0
        }
     
        allColorViews[index].layer.borderWidth = Specs.colorsBorderWidth
        selectedColorIndex = index
    }

    func setColors(_ colors: [UIColor]) {
        guard colors.count >= allColorViews.count else { return }
        for i in 0..<allColorViews.count {
            allColorViews[i].backgroundColor = colors[i]
        }
    }

    private func configureViews() {
        plate.backgroundColor = UIColor.clear

        allColorViews = [color0, color1, color2, color3, color4, color5, color6]
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
        name.backgroundColor = Theme.main.colors.secondaryBackground
        name.font = Theme.main.fonts.listBody
        name.placeholder = "sticker_name_placeholder".localized
        separator1.backgroundColor = Theme.main.colors.separator

        emojiLabel.text = "emoji_label".localized
        emoji.backgroundColor = Theme.main.colors.secondaryBackground
        emoji.font = Theme.main.fonts.listBody
        emoji.delegate = self
        emoji.placeholder = ""
        separator2.backgroundColor = Theme.main.colors.separator

        previewLabel.text = "preview_label".localized
        previewPlate.backgroundColor = Theme.main.colors.secondaryBackground
        previewPlate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        previewPlate.clipsToBounds = true
        separator3.backgroundColor = Theme.main.colors.separator

        stickerBackground.backgroundColor = Theme.main.colors.background
        stickerBackground.layer.cornerRadius = Theme.main.specs.platesCornerRadius
    }
    
    override func updateColors() {
        allColorViews = [color0, color1, color2, color3, color4, color5, color6]
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
        
        let index = Int(ceil(loc.x / (stackView.frame.width / 7))) - 1
        
        if index >= 0 && index < 7 {
            setSelectedColorIndex(index)
            onColorSelected?(index)
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

