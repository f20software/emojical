//
//  GoalDetailsEditCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalDetailsEditCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var goalIcon: GoalAwardView!
    @IBOutlet weak var name: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalEditData) {
        
        goalIcon.text = data.award.emoji
        goalIcon.labelColor = data.award.backgroundColor
        goalIcon.clockwise = (data.award.direction == .positive)
        goalIcon.progress = CGFloat(data.award.progress)
        goalIcon.progressColor = data.award.progressColor
        
        name.text = data.goal.name
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

