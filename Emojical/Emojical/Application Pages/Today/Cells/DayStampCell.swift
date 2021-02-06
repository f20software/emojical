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
        
        if data.isUsed {
            badgeView.isHidden = false
        } else {
            badgeView.isHidden = true
        }
        
        // Sticker size delta constraint
        stickerAndSelectionSizeDelta.constant = sizeDelta
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        badgeView.layer.cornerRadius = badgeView.bounds.width / 2.0
        badgeView.isHidden = true
        badgeView.backgroundColor = Theme.main.colors.tint
    }
}
