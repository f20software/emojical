//
//  NoGoalsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/11/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NoGoalsCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var text: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: String) {
        text.text = data
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        text.font = Theme.main.fonts.listBody
        text.textColor = Theme.main.colors.secondaryText
    }
}
