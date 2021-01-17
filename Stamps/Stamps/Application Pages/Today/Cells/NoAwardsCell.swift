//
//  NoAwardsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/17/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NoAwardsCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var text: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        text.text = nil
    }
    
    // MARK: - Public view interface
    
    func configure(for data: String) {
        text.text = data
    }
}
