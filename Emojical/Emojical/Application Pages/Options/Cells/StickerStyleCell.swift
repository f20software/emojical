//
//  StickerStyleCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/1/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerStyleCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var sticker1: StickerView!
    @IBOutlet weak var sticker2: StickerView!
    @IBOutlet weak var selection: UIView!
    @IBOutlet weak var previewBackground: UIView!
    @IBOutlet weak var selectionPosition: NSLayoutConstraint!

    // MARK: - State
    
    private var style: StickerStyle = .default {
        didSet {
            selectionPosition.constant = style == .default ? 8.0 : -53.0
        }
    }
    
    /// Called after switch value changed
    var onValueChanged: ((StickerStyle) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for text: String, sticker: Stamp, style: StickerStyle) {
        labelText.text = text
        sticker1.text = sticker.label
        sticker1.color = sticker.color
        sticker2.text = sticker.label
        sticker2.color = sticker.color
        self.style = style
    }

    // MARK: - Private helpers

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    private func configureViews() {
        labelText.font = Theme.main.fonts.listBody
        backgroundColor = UIColor.clear
        
        previewBackground.backgroundColor = Theme.main.colors.secondaryBackground
        previewBackground.layer.cornerRadius = 10.0
        
        sticker1.style = .default
        sticker2.style = .borderless
        
        selection.tintColor = Theme.main.colors.tint
        
        sticker1.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(sticker1Tapped)))
        
        sticker2.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(sticker2Tapped)))
    }
    
    @objc private func sticker1Tapped() {
        guard style != .default else { return }
        style = .default
        onValueChanged?(style)
    }

    @objc private func sticker2Tapped() {
        guard style != .borderless else { return }
        style = .borderless
        onValueChanged?(style)
    }
}
