//
//  StickerDetailsEditCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerDetailsEditCell: UICollectionViewCell {

    // MARK: - Outlets

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
        
        if let index = allColorViews.firstIndex(where: {
            print($0.backgroundColor?.hex, data.sticker.color.hex)
            return $0.backgroundColor?.hex == data.sticker.color.hex
        }) {
            setSelectedColorIndex(index)
        }
    }
    
    // MARK: - Private helpers

    func setSelectedColorIndex(_ index: Int) {
        // Clear previous value
        if selectedColorIndex >= 0 {
            allColorViews[selectedColorIndex].layer.borderWidth = 0.0
        }
     
        allColorViews[index].layer.borderWidth = 3.0
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
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
            view.backgroundColor = UIColor.systemBackground
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 0.0
        }
        
        let labels: [UILabel] = [nameLabel, emojiLabel]
        for label in labels {
            label.font = Theme.shared.fonts.formFieldCaption
            label.textColor = Theme.shared.colors.secondaryText
        }

        nameLabel.text = "Name:"
        name.backgroundColor = UIColor.systemGray6
        name.font = Theme.shared.fonts.listBody

        emojiLabel.text = "Emoji:"
        emoji.backgroundColor = UIColor.systemGray6
        emoji.font = Theme.shared.fonts.listBody
    }
    
    @IBAction func textChanged(_ sender: Any) {
        onValueChanged?()
    }

    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: self.stackView)
        let index = Int(ceil(loc.x / (self.stackView.frame.width / 7))) - 1
        
        if index >= 0 && index < 7 {
            onColorSelected?(index)
            setSelectedColorIndex(index)
        }
    }
}
