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
    @IBOutlet weak var goalIcon: GoalAwardView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalExampleData) {
        title.text = data.name
        subTitle.text = data.description
        
        if let sticker = data.stickers.first {
            goalIcon.text = sticker.emoji
            goalIcon.labelColor = UIColor(hex: sticker.color.rawValue).withAlphaComponent(0.5)
            goalIcon.clockwise = true
            goalIcon.progress = 1.0
            goalIcon.progressColor = Theme.main.colors.goalReachedBorder
            goalIcon.setNeedsDisplay()
        }
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
        
        goalIcon.progressLineWidth = Specs.progressLineWidth
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

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 3.0
}
