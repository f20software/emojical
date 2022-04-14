//
//  DayStampCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayStampCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var stickerAndSelectionSizeDelta: NSLayoutConstraint!
    @IBOutlet weak var badgeViewDot: UIView!
    @IBOutlet weak var badgeViewOutline: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        backgroundColor = UIColor.clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sticker.text = nil
        sticker.color = UIColor.clear
    }
    
    // MARK: - Public view interface
    
    func configure(for data: StickerData, sizeDelta: CGFloat) {
        sticker.text = data.label
        sticker.color = data.color
        tag = Int(data.stampId ?? 0)
        
        (LocalSettings.shared.stickerStyle == .borderless ?
            badgeViewOutline : badgeViewDot)?.isHidden = data.isUsed == false
        
        // Sticker size delta constraint
        stickerAndSelectionSizeDelta.constant = sizeDelta
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        badgeViewDot.layer.cornerRadius = badgeViewDot.bounds.width / 2.0
        badgeViewDot.isHidden = true
        badgeViewDot.backgroundColor = Theme.main.colors.tint

        badgeViewOutline.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        badgeViewOutline.isHidden = true
        badgeViewOutline.backgroundColor = UIColor.clear
        badgeViewOutline.layer.borderColor = Theme.main.colors.tint.cgColor
        badgeViewOutline.layer.borderWidth = 3.0
    }
    
    override func updateColors() {
        badgeViewOutline.layer.borderColor = Theme.main.colors.tint.cgColor
    }
}
