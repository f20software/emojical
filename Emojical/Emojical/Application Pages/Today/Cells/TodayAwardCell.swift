//
//  TodayAwardCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/07/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class TodayAwardCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var goal: GoalIconView!
    @IBOutlet weak var award: AwardIconView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public view interface
    
    func configure(for data: GoalOrAwardIconData) {
        goal.isHidden = true
        award.isHidden = true

        switch data {
        case .award(let awardData):
            award.isHidden = false
            award.labelText = awardData.emoji
            award.labelBackgroundColor = awardData.backgroundColor
            award.borderColor = awardData.borderColor

        case .goal(let goalData):
            goal.isHidden = false
            goal.labelText = goalData.emoji
            goal.labelBackgroundColor = goalData.backgroundColor
            goal.progress = CGFloat(goalData.progress)
            goal.progressColor = goalData.progressColor
            goal.clockwise = (goalData.direction == .positive)
        }
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {
        goal.progressLineWidth = Theme.main.specs.progressWidthSmall
        goal.progressLineGap = Theme.main.specs.progressGapSmall
        award.borderWidth = Theme.main.specs.progressWidthSmall
    }
}
