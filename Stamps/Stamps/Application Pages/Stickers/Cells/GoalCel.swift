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
    @IBOutlet weak var award: AwardView!
    @IBOutlet weak var progress: ProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalAwardData) {
        title.text = data.name
        subTitle.text = data.details
        tag = Int(data.goalId)
        
        award.configure(color: data.color, dashes: data.dashes)
        award.backgroundColor = UIColor.clear
        
        progress.tintColor = data.progressColor
        progress.progress = data.progress
        progress.lineWidth = 3.0
        progress.backgroundColor = UIColor.clear
        
        progress.setNeedsDisplay()
        award.setNeedsDisplay()
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.layer.cornerRadius = Specs.cornerRadius
        plate.backgroundColor = UIColor.systemGray6
        plate.clipsToBounds = true
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0
}
