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
    @IBOutlet weak var goalIcon: GoalAwardView!
    @IBOutlet weak var details: UILabel!

    /// When cell is selected we show details text instead of award icon
    override var isHighlighted: Bool {
        didSet {
            goalIcon.isHidden = isHighlighted
            details.isHidden = !isHighlighted
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: AwardRecapData) {
        tag = Int(data.progress.goalId ?? 0)
        
        details.text = data.title
        details.isHidden = !isHighlighted
        
        goalIcon.text = data.progress.emoji
        goalIcon.labelColor = data.progress.backgroundColor
        goalIcon.clockwise = (data.progress.direction == .positive)
        goalIcon.progress = CGFloat(data.progress.progress)
        goalIcon.progressColor = data.progress.progressColor
        goalIcon.setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isHighlighted = false
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        goalIcon.progressLineWidth = Specs.progressLineWidth
        goalIcon.emojiFontSize = Specs.emojiFontSize
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 6.0
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 52.0

}
