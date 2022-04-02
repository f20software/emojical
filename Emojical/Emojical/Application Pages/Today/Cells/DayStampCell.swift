//
//  DayStampCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayStampCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var stickerAndSelectionSizeDelta: NSLayoutConstraint!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeView2: UIView!

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
        
        if LocalSettings.shared.stickerStyle == .borderless {
            badgeView2.isHidden = !data.isUsed
        } else {
            badgeView.isHidden = !data.isUsed
        }
        
        // Sticker size delta constraint
        stickerAndSelectionSizeDelta.constant = sizeDelta
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        badgeView.layer.cornerRadius = badgeView.bounds.width / 2.0
        badgeView.isHidden = true
        badgeView.backgroundColor = Theme.main.colors.tint

        badgeView2.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        badgeView2.isHidden = true
        badgeView2.backgroundColor = UIColor.clear
        badgeView2.layer.borderColor = Theme.main.colors.tint.cgColor
        badgeView2.layer.borderWidth = 3.0
    }
}
