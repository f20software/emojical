//
//  GoalDetailsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalDetailsCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var goalDescription: UILabel!
    @IBOutlet weak var goalIcon: GoalAwardView!
    @IBOutlet weak var goalBackground: UIView!
    @IBOutlet weak var stickers: UILabel!
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

    // MARK: - Public view interface

    func configure(for data: GoalViewData) {
        progressIcon = data.progress
        fullIcon = data.award
        
        goalDescription.text = data.details
        stickers.text = "stickers_title".localized + ": \(data.stickers.joined(separator: ", "))"
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
        plate.backgroundColor = Theme.main.colors.secondaryBackground
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
        
        goalIcon.progressLineWidth = Specs.progressLineWidth
        goalIcon.emojiFontSize = Specs.emojiFontSize
        
        goalBackground.backgroundColor = Theme.main.colors.background
        goalBackground.layer.cornerRadius = goalBackground.bounds.width / 2.0

        updateFonts()
    }
    
    override func updateFonts() {
        goalDescription.font = Theme.main.fonts.listBody
        stickers.font = Theme.main.fonts.listBody
        currentProgress.font = Theme.main.fonts.listBody
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 4.0
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 50.0
}
