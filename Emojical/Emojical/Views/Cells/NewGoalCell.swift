//
//  NewGoalCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NewGoalCell: ThemeObservingCollectionCell {

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
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.layer.borderWidth = Specs.borderWidth
        plate.backgroundColor = UIColor.clear
        plate.clipsToBounds = true

        title.font = Theme.main.fonts.boldButtons
        title.text = "create_goal_button".localized
        updateColors()
    }
    
    override func updateColors() {
        plate.layer.borderColor = Theme.main.colors.secondaryBackground.cgColor
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Border width
    static let borderWidth: CGFloat = 2.0
}
