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
    @IBOutlet weak var selectionView: UIView!
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
        // sticker.isEnabled = true
    }
    
    // MARK: - Public view interface
    
    func configure(for data: StickerData, sizeDelta: CGFloat) {
        sticker.text = data.label
        sticker.color = data.color
        tag = Int(data.stampId ?? 0)
        
        if data.isUsed {
            badgeView.isHidden = false
//            selectionView.isHidden = false
//            selectionView.layer.borderColor = data.color.cgColor
        } else {
            badgeView.isHidden = true
//            selectionView.isHidden = true
        }
        
        // Sticker size delta constraint
        stickerAndSelectionSizeDelta.constant = sizeDelta
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        selectionView.layer.cornerRadius = Specs.selectionCornerRadius
        selectionView.layer.borderWidth = Specs.selectionBorderWidth
        badgeView.layer.cornerRadius = badgeView.bounds.width / 2.0
        badgeView.backgroundColor = UIColor.appTintColor
        
        selectionView.isHidden = true
        badgeView.isHidden = true
        
    }
}

// MARK: - Specs

fileprivate struct Specs {
    
    /// Selection corner radius
    static let selectionCornerRadius: CGFloat = 12.0

    /// Selection border thickness
    static let selectionBorderWidth: CGFloat = 2.0
}
