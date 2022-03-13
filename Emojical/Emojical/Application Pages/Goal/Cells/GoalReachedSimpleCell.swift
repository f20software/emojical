//
//  GoalDetailsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalReachedSimpleCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var statistics: UILabel!
    @IBOutlet weak var statisticsLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkMark: UIImageView!

    // MARK: - State

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }

    // MARK: - Public view interface

    func configure(for data: GoalReachedData) {
        statistics.text = Language.goalReachedDescription(data.count, lastUsed: data.lastUsed)
        
        if data.count == 0 {
            checkMark.isHidden = true
            statisticsLeadingConstraint.constant = -checkMark.frame.width
        } else {
            checkMark.isHidden = false
            statisticsLeadingConstraint.constant = 15
        }
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = Theme.main.colors.secondaryBackground
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
        statistics.font = Theme.main.fonts.listBody
        checkMark.tintColor = Theme.main.colors.oneTimeGoalReachedCheckMark
    }
}
