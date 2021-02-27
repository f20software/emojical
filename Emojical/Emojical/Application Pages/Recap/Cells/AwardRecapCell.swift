//
//  AwardRecapCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class AwardRecapCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var goal: GoalIconView!
    @IBOutlet weak var award: AwardIconView!
    @IBOutlet weak var details: UILabel!

    // MARK: - State
    
    private var visibleView: UIView?
    
    /// When cell is selected we show details text instead of award icon
    override var isHighlighted: Bool {
        didSet {
            visibleView?.isHidden = isHighlighted
            details.isHidden = !isHighlighted
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: AwardRecapData) {
        // tag = Int(data.progress.goalId ?? 0)
        
        details.text = data.title
        details.isHidden = !isHighlighted
        
        goal.isHidden = true
        award.isHidden = true
        
        switch data.progress {
        case .award(let awardData):
            award.isHidden = false
            visibleView = award
            award.labelText = awardData.emoji
            award.labelBackgroundColor = awardData.backgroundColor
            award.borderColor = awardData.borderColor

        case.goal(let goalData):
            goal.isHidden = false
            visibleView = goal
            goal.labelText = goalData.emoji
            goal.labelBackgroundColor = goalData.backgroundColor
            goal.clockwise = (goalData.direction == .positive)
            goal.progress = CGFloat(goalData.progress)
            goal.progressColor = goalData.progressColor
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isHighlighted = false
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear

        goal.progressLineWidth = Theme.main.specs.progressWidthLarge
        goal.progressLineGap = Theme.main.specs.progressGapLarge
        award.borderWidth = Theme.main.specs.progressWidthLarge
        
        goal.emojiFontSize = Specs.emojiFontSize
        award.emojiFontSize = Specs.emojiFontSize
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 52.0

}
