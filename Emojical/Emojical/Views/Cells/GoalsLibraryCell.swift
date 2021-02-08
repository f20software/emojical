//
//  GoalsLibraryCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/7/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalsLibraryCell: ThemeObservingCollectionCell {

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
        title.text = "goals_examples_button".localized
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
