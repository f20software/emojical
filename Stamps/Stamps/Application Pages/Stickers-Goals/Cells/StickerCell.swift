//
//  StickerCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sticker.text = nil
        tag = 0
    }
    
    // MARK: - Public view interface

    func configure(for data: StickerData) {
        sticker.color = data.color
        sticker.text = data.label
        tag = Int(data.stampId ?? 0)
    }

    // MARK: - Private helpers

    private func configureViews() {
    }
}
