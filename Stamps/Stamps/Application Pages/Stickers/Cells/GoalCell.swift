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

    func configure(for data: GoalAwardData) {
        title.text = data.name
        subTitle.text = data.details
        tag = Int(data.goalId)
        
        goalIcon.progress = data.progress
        goalIcon.progressLineWidth = 3.0
        goalIcon.progressColor = UIColor.appTintColor
        goalIcon.labelColor = data.color
        goalIcon.text = data.emoji
        
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
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0
}
