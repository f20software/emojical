//
//  GoalStreakCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/04/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalStreakCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var goal: GoalIconView!
    @IBOutlet weak var award: AwardIconView!
    @IBOutlet weak var dots: GoalStreakView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public view interface
    
    func configure(for data: GoalStreakData) {

        switch data.icon {
        case .goal(let iconData):
//            goal.isHidden = false
//            award.isHidden = true
            goal.labelText = nil // iconData.emoji
            goal.labelBackgroundColor = Theme.main.colors.secondaryBackground // iconData.backgroundColor
            goal.clockwise = (iconData.direction == .positive)
            goal.progress = CGFloat(iconData.progress)
            goal.progressColor = Theme.main.colors.tint // iconData.progressColor

            award.labelText = iconData.emoji
            award.borderColor = iconData.progressColor
            award.labelBackgroundColor = iconData.backgroundColor

        case .award(let awardData):
//            award.isHidden = false
//            goal.isHidden = true
            goal.labelText = awardData.emoji
            goal.labelBackgroundColor = awardData.backgroundColor
            goal.progressColor = awardData.borderColor
            goal.progress = 1.0

            award.labelText = awardData.emoji
            award.borderColor = awardData.borderColor
            award.labelBackgroundColor = awardData.backgroundColor
        }
        
        
        

        
        //        sticker.text = data.label
//        sticker.color = data.color
        
        dots.count = 5
        dots.data = data.history
        // dots.dotRadius = 15
        // dots.setNeedsDisplay()
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        dots.backgroundColor = UIColor.clear

        goal.progressLineWidth = Theme.main.specs.progressWidthSmall
        goal.progressLineGap = Theme.main.specs.progressGapSmall
        award.borderWidth = Theme.main.specs.progressWidthSmall

        dots.backgroundColor = Theme.main.colors.background
        dots.lineColor = Theme.main.colors.tint
        dots.dotRadius = 8.0

//        dots.lineWidth = Specs.lineWidth
//        dots.cornerRadius = Specs.cornerRadius
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Stat squares line width
    static let lineWidth: CGFloat = 2.0

    /// Stat squares corner radius
    static let cornerRadius: CGFloat = 2.0
}
