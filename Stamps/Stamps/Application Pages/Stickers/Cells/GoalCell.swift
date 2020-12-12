//
//  GoalCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var goalIcon: GoalAwardView!
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
        
        goalIcon.text = data.progress.emoji
        goalIcon.labelColor = data.progress.backgroundColor
        goalIcon.progress = data.progress.progress
        goalIcon.progressColor = data.progress.progressColor
        
        if data.count > 0 {
            count.text = "  \(data.count)  "
            count.isHidden = false
        } else {
            count.text = nil
            count.isHidden = true
        }
        
        goalIcon.setNeedsDisplay()
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.layer.cornerRadius = Specs.cornerRadius
        plate.backgroundColor = UIColor.systemGray6
        plate.clipsToBounds = true
        
        count.layer.cornerRadius = count.font.pointSize * 0.6
        count.clipsToBounds = true
        count.backgroundColor = UIColor.appTintColor

        goalIcon.progressLineWidth = 3.0
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0
}
