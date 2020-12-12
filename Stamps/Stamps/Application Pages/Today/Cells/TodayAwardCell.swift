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
        // backgroundColor = UIColor.blue
    }
    
    // MARK: - Public view interface
    
    func configure(for data: TodayAwardData) {
        awardIcon.progress = data.progress
        awardIcon.progressLineWidth = 3.0
        awardIcon.progressColor = UIColor.appTintColor
        awardIcon.labelColor = data.color
        awardIcon.text = data.emoji
        
        awardIcon.setNeedsDisplay()
    }
}
