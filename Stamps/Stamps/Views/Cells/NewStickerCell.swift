//
//  NewStickerCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NewStickerCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var border: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var ratio: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(iconRatio: CGFloat = 1.0) {
        ratio.constant = border.bounds.width * (1 - iconRatio)
    }

    // MARK: - Private helpers

    private func configureViews() {
        border.backgroundColor = UIColor.clear
        icon.image = UIImage(systemName: "plus.square", withConfiguration: UIImage.SymbolConfiguration(weight: .light))
    }
}
