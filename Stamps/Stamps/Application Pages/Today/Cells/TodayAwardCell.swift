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

    @IBOutlet weak var award: AwardView!
    @IBOutlet weak var progress: ProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // backgroundColor = UIColor.blue
    }
    
    // MARK: - Public view interface
    
    func configure(for data: TodayAwardData) {
        award.configure(color: data.color, dashes: data.dashes)
        award.backgroundColor = UIColor.clear
        
        progress.tintColor = data.progressColor
        progress.progress = data.progress
        progress.lineWidth = 3.0
        progress.backgroundColor = UIColor.clear
        
        progress.setNeedsDisplay()
        award.setNeedsDisplay()
    }
}
