//
//  GoalExampleCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/6/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalExampleCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var award: AwardIconView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalExampleData) {
        title.text = data.name
        subTitle.text = data.description
        
        if let sticker = data.stickers.first {
            award.labelText = sticker.emoji
            award.labelBackgroundColor = sticker.color.withAlphaComponent(0.5)
            award.borderColor = Theme.main.colors.reachedGoalBorder
        }
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
        
        award.borderWidth = Theme.main.specs.progressWidthSmall
        plate.backgroundColor = Theme.main.colors.secondaryBackground
        title.textColor = Theme.main.colors.text
        subTitle.textColor = Theme.main.colors.secondaryText
        updateFonts()
    }
    
    override func updateFonts() {
        title.font = Theme.main.fonts.listTitle
        subTitle.font = Theme.main.fonts.listBody
    }
}
