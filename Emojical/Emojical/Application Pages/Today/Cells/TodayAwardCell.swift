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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        awardIcon.labelColor = UIColor.clear
        awardIcon.text = nil
        awardIcon.progress = 0.0
        awardIcon.progressColor = UIColor.clear
        awardIcon.setNeedsDisplay()
    }
    
    // MARK: - Public view interface
    
    func configure(for data: GoalAwardData) {
        awardIcon.text = data.emoji
        awardIcon.labelColor = data.backgroundColor
        awardIcon.progress = CGFloat(data.progress)
        awardIcon.progressColor = data.progressColor
        awardIcon.clockwise = (data.direction == .positive)
        awardIcon.setNeedsDisplay()
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 3.0
}
