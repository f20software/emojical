//
//  GoalCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalCell: ThemeObservingCollectionCell {

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
        goalIcon.clockwise = (data.progress.direction == .positive)
        goalIcon.progress = CGFloat(data.progress.progress)
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
        plate.layer.cornerRadius = Theme.shared.specs.platesCornerRadius
        plate.clipsToBounds = true
        
        count.layer.cornerRadius = count.font.pointSize * 0.6
        count.clipsToBounds = true
        goalIcon.progressLineWidth = Specs.progressLineWidth
        
        plate.backgroundColor = Theme.shared.colors.secondaryBackground
        count.backgroundColor = Theme.shared.colors.tint
        count.textColor = Theme.shared.colors.background
        title.textColor = Theme.shared.colors.text
        subTitle.textColor = Theme.shared.colors.secondaryText
    }
    
    override func updateFonts() {
        title.font = Theme.shared.fonts.listTitle
        subTitle.font = Theme.shared.fonts.listBody
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 3.0
}
