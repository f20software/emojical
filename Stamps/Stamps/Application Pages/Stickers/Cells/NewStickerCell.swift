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

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure() {
    }

    // MARK: - Private helpers

    private func configureViews() {
        border.layer.cornerRadius = Specs.cornerRadius
        border.backgroundColor = UIColor.clear
        border.layer.borderWidth = 2.0
        border.layer.borderColor = UIColor.systemGray6.cgColor
        border.clipsToBounds = true
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0
}
