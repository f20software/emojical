//
//  GoalDetailsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalDetailsCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var goalDescription: UILabel!
    @IBOutlet weak var goalIcon: GoalAwardView!
    @IBOutlet weak var statistics: UILabel!
    @IBOutlet weak var currentProgress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalViewData) {
        
        goalIcon.text = data.award.emoji
        goalIcon.labelColor = data.award.backgroundColor
        goalIcon.clockwise = (data.award.direction == .positive)
        goalIcon.progress = CGFloat(data.award.progress)
        goalIcon.progressColor = data.award.progressColor
        
        goalDescription.text = data.details
        statistics.text = data.statis
        currentProgress.text = data.progressText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.systemGray6
        plate.layer.cornerRadius = Specs.cornerRadius
        plate.clipsToBounds = true
        goalIcon.progressLineWidth = Specs.progressLineWidth
        goalIcon.emojiFontSize = Specs.emojiFontSize
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0

    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 4.0
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 40.0
}

