//
//  GoalCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var goal: GoalIconView!
    @IBOutlet weak var award: AwardIconView!
    @IBOutlet weak var count: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalData) {
        title.text = data.name
        subTitle.text = data.details
        tag = Int(data.goalId)
        
        switch data.icon {
        case .goal(let iconData):
            goal.isHidden = false
            award.isHidden = true
            goal.labelText = iconData.emoji
            goal.labelBackgroundColor = iconData.backgroundColor
            goal.clockwise = (iconData.direction == .positive)
            goal.progress = CGFloat(iconData.progress)
            goal.progressColor = iconData.progressColor
            
        case .award(let iconData):
            award.isHidden = false
            goal.isHidden = true
            award.labelText = iconData.emoji
            award.labelBackgroundColor = iconData.backgroundColor
            award.borderColor = iconData.borderColor
        }
        
        
        if data.count > 0 {
            count.text = "  \(data.count)  "
            count.isHidden = false
        } else {
            count.text = nil
            count.isHidden = true
        }
        
        goal.setNeedsDisplay()
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
        
        count.layer.cornerRadius = count.font.pointSize * 0.6
        count.clipsToBounds = true

        goal.progressLineWidth = Theme.main.specs.progressWidthSmall
        goal.progressLineGap = Theme.main.specs.progressGapSmall
        award.borderWidth = Theme.main.specs.progressWidthSmall

        plate.backgroundColor = Theme.main.colors.secondaryBackground
        count.backgroundColor = Theme.main.colors.tint
        count.textColor = Theme.main.colors.background
        title.textColor = Theme.main.colors.text
        subTitle.textColor = Theme.main.colors.secondaryText
        updateFonts()
    }
    
    override func updateFonts() {
        title.font = Theme.main.fonts.listTitle
        subTitle.font = Theme.main.fonts.listBody
    }
}
