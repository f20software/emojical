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
    @IBOutlet weak var goalBackground: UIView!
    @IBOutlet weak var stickers: UILabel!
    @IBOutlet weak var statistics: UILabel!
    @IBOutlet weak var currentProgress: UILabel!

    /// User tapped on the Delete button
    var onIconTapped: (() -> Void)?
    
    // MARK: - State
    private var showCurrentProgress: Bool = false
    
    private var progressIcon: GoalAwardData!
    private var fullIcon: GoalAwardData!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Public view interface

    func configure(for data: GoalViewData) {
        progressIcon = data.progress
        fullIcon = data.award
        
        goalDescription.text = data.details
        statistics.text = data.statis
        stickers.text = "Stickers: \(data.stickers.joined(separator: ", "))"
        currentProgress.text = data.progressText
        
        updateIcon()
    }
    
    func toggleState() {
        showCurrentProgress = !showCurrentProgress
        updateIcon()
    }

    // MARK: - Private helpers

    private func updateIcon() {
        if showCurrentProgress {
            goalIcon.text = progressIcon.emoji
            goalIcon.labelColor = progressIcon.backgroundColor
            goalIcon.clockwise = (progressIcon.direction == .positive)
            goalIcon.progress = CGFloat(progressIcon.progress)
            goalIcon.progressColor = progressIcon.progressColor
        } else {
            goalIcon.text = fullIcon.emoji
            goalIcon.labelColor = fullIcon.backgroundColor
            goalIcon.clockwise = (fullIcon.direction == .positive)
            goalIcon.progress = CGFloat(fullIcon.progress)
            goalIcon.progressColor = fullIcon.progressColor
        }
        goalIcon.setNeedsDisplay()
    }
    
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: goalIcon)
        if goalIcon.bounds.contains(loc) {
            onIconTapped?()
        }
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.systemGray6
        plate.layer.cornerRadius = Specs.cornerRadius
        plate.clipsToBounds = true
        
        goalIcon.progressLineWidth = Specs.progressLineWidth
        goalIcon.emojiFontSize = Specs.emojiFontSize
        
        goalBackground.backgroundColor = UIColor.systemBackground
        goalBackground.layer.cornerRadius = goalBackground.bounds.width / 2.0
        
        goalDescription.font = Theme.shared.fonts.listBody
        statistics.font = Theme.shared.fonts.listBody
        stickers.font = Theme.shared.fonts.listBody
        currentProgress.font = Theme.shared.fonts.listBody
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0

    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 4.0
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 50.0
}

