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

    @IBOutlet weak var awardIcon: GoalAwardView!

    override func awakeFromNib() {
        super.awakeFromNib()
        awardIcon.progressLineWidth = Specs.progressLineWidth
    }
    
    // MARK: - Public view interface
    
    func configure(for data: GoalAwardData) {
        awardIcon.progress = data.progress
        awardIcon.progressColor = data.progressColor
        awardIcon.labelColor = data.backgroundColor
        awardIcon.text = data.emoji
        awardIcon.setNeedsDisplay()
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 3.0
}
