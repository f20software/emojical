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
    @IBOutlet weak var name: UILabel!
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
        tag = Int(data.sticker.id ?? -1)
        sticker.text = data.sticker.label
        sticker.color = data.sticker.color
        name.text = data.sticker.name
        selectedMark.isHidden = !data.selected
    }
    
    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        name.font = Theme.shared.fonts.listTitle
        selectedMark.tintColor = Theme.shared.colors.tint
    }
}

