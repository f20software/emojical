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

    @IBOutlet weak var goal: GoalAwardView!
    @IBOutlet weak var award: AwardView!

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
            // tag = Int(goalData.goalId ?? 0)
            goal.isHidden = false
            goal.text = goalData.emoji
            goal.labelColor = goalData.backgroundColor
            goal.progress = CGFloat(goalData.progress)
            goal.progressColor = goalData.progressColor
            goal.clockwise = (goalData.direction == .positive)
        }
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {
        goal.progressLineWidth = Specs.progressLineWidth
        goal.progressLineGap = Specs.progressLineGap
        award.borderWidth = Specs.progressLineWidth
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 3.0

    /// Gap between progress line and the icon
    static let progressLineGap: CGFloat = 1.0
}
