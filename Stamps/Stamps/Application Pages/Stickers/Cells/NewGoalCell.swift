//
//  NewGoalCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NewGoalCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure() {
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.layer.cornerRadius = Specs.cornerRadius
        plate.backgroundColor = UIColor.clear
        plate.layer.borderWidth = 2.0
        plate.layer.borderColor = UIColor.systemGray6.cgColor
        plate.clipsToBounds = true
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0
}
