//
//  SelectStickerCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/23/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class SelectStickerCell: UICollectionViewCell {
    
    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var selectedMark: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedMark.isHidden = true
    }
    
    func configure(for data: SelectStickerData) {
        // Save off sticker Id, so we can use later when select / deselected specific cell
        tag = Int(data.sticker.id ?? -1)
        
        sticker.text = data.sticker.label
        sticker.color = data.sticker.color
        
        selectedMark.isHidden = !data.selected
    }
    
    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        selectedMark.tintColor = Theme.main.colors.tint
    }
}

