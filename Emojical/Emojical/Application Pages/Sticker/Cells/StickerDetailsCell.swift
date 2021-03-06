//
//  StickerDetailsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerDetailsCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var stickerBackground: UIView!
    @IBOutlet weak var usage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }

    // MARK: - Public view interface

    func configure(for data: StickerViewData) {
        usage.text = data.usage

        sticker.text = data.sticker.label
        sticker.color = data.sticker.color
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = Theme.main.colors.secondaryBackground
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
        
        stickerBackground.backgroundColor = Theme.main.colors.background
        stickerBackground.layer.cornerRadius = Theme.main.specs.platesCornerRadius

        updateFonts()
    }
    
    override func updateFonts() {
        usage.font = Theme.main.fonts.listBody
    }
    
}
