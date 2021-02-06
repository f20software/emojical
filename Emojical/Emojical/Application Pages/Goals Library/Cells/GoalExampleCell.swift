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
//        subTitle.text = data.details
//        tag = Int(data.goalId)
//        
//        goalIcon.text = data.progress.emoji
//        goalIcon.labelColor = data.progress.backgroundColor
//        goalIcon.clockwise = (data.progress.direction == .positive)
//        goalIcon.progress = CGFloat(data.progress.progress)
//        goalIcon.progressColor = data.progress.progressColor
//        goalIcon.setNeedsDisplay()
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
