//
//  NoAwardsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/17/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NoAwardsCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var textLabel: UILabel!

    // MARK: - View life cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.text = nil
    }
    
    // MARK: - Public view interface
    
    func configure(for data: String) {
        textLabel.text = data

        updateFonts()
    }
    
    override func updateFonts() {
        textLabel.font = Theme.main.fonts.cellDescription
    }
}
