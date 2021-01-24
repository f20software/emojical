//
//  StickerDetailsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerDetailsCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var stickerIcon: StickerView!
    @IBOutlet weak var stickerBackground: UIView!
    @IBOutlet weak var statistics: UILabel!
    @IBOutlet weak var usage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }

    // MARK: - Public view interface

    func configure(for data: StickerViewData) {
        statistics.text = data.statistics
        usage.text = data.usage

        stickerIcon.text = data.sticker.label
        stickerIcon.color = data.sticker.color
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.systemGray6
        plate.layer.cornerRadius = Specs.cornerRadius
        plate.clipsToBounds = true
        
        stickerBackground.backgroundColor = UIColor.systemBackground
        stickerBackground.layer.cornerRadius = 10.0
        
        statistics.font = Theme.shared.fonts.listBody
        usage.font = Theme.shared.fonts.listBody
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0

    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 4.0
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 50.0
}

