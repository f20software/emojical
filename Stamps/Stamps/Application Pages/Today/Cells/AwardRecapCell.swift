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
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var goalIcon: GoalAwardView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: AwardRecapData) {
        title.text = data.title
        tag = Int(data.progress.goalId ?? 0)
        
        goalIcon.text = data.progress.emoji
        goalIcon.labelColor = data.progress.backgroundColor
        goalIcon.clockwise = (data.progress.direction == .positive)
        goalIcon.progress = CGFloat(data.progress.progress)
        goalIcon.progressColor = data.progress.progressColor
        
        goalIcon.setNeedsDisplay()
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        goalIcon.progressLineWidth = Specs.progressLineWidth
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 3.0
}
