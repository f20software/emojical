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
    @IBOutlet weak var goal: GoalIconView!
    @IBOutlet weak var award: AwardIconView!
    @IBOutlet weak var goalBackground: UIView!
    @IBOutlet weak var stickers: UILabel!
    @IBOutlet weak var currentProgress: UILabel!

    /// User tapped on the Delete button
    var onIconTapped: (() -> Void)?
    
    // MARK: - State

    private var animating = false

    private var progressIcon: GoalIconData!
    private var fullIcon: AwardIconData!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalViewData) {
        progressIcon = data.goalIcon
        fullIcon = data.awardIcon
        
        goalDescription.text = data.details
        stickers.text = "stickers_title".localized + ": \(data.stickers.joined(separator: ", "))"
        currentProgress.text = data.progressText

        award.isHidden = false
        award.alpha = 1
        goal.isHidden = true
        goal.alpha = 1
        
        goal.labelText = progressIcon.emoji
        goal.labelBackgroundColor = progressIcon.backgroundColor
        goal.clockwise = (progressIcon.direction == .positive)
        goal.progressColor = progressIcon.progressColor

        award.labelText = fullIcon.emoji
        award.labelBackgroundColor = fullIcon.backgroundColor
        award.borderColor = fullIcon.borderColor
    }
    
    func animateIcon() {
        guard animating == false else { return }
        animating = true

        award.isHidden = true
        goal.isHidden = false
        goal.progress = (progressIcon.direction == .positive) ? 0.0 : 1.0

        goal.animateProgress(to: CGFloat(progressIcon.progress), duration: Specs.animation.progress, completion: {
            
            self.award.alpha = 0
            self.award.isHidden = false
            
            UIView.animate(withDuration: Specs.animation.transitionToAward, delay: Specs.animation.delayBeforeAward, options: [.curveLinear], animations: {
                self.award.alpha = 1
                self.goal.alpha = 0
            }, completion: {_ in
                self.award.isHidden = false
                self.goal.isHidden = true
                self.goal.alpha = 1
                self.animating = false
            })
        })
    }

    // MARK: - Private helpers

    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: goal)
        if goal.bounds.contains(loc) {
            onIconTapped?()
        }
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = Theme.main.colors.secondaryBackground
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
        
        goal.emojiFontSize = Specs.emojiFontSize
        goal.progressLineWidth = Theme.main.specs.progressWidthMedium
        goal.progressLineGap = Theme.main.specs.progressGapMedium
        
        award.emojiFontSize = Specs.emojiFontSize
        award.borderWidth = Theme.main.specs.progressWidthMedium
        award.isHidden = true

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
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 50.0

    /// Animation durations
    struct animation {

        /// Filling up progress circle duration
        static let progress: TimeInterval = 1.0

        /// Delaty before transition to award icon duration
        static let delayBeforeAward: TimeInterval = 0.5

        /// Transition to award icon duration
        static let transitionToAward: TimeInterval = 0.5
    }
}

