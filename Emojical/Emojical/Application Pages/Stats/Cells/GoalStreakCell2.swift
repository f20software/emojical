//
//  GoalStreakCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/04/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalStreakCell2: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var goal: GoalIconView!
    @IBOutlet weak var award: AwardIconView!
    @IBOutlet weak var totalLabel: UILabelWithContentInset!
    @IBOutlet weak var streakLabel: UILabelWithContentInset!

    /// Called when user tapped on the total or streak counter label
    var onCounterTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Public view interface
    
    func configure(for data: GoalStreakData2, sortOrder: GoalStreakSortOrder) {
        switch data.icon {
        case .goal(let iconData):
            goal.isHidden = false
            award.isHidden = true
            goal.labelText = iconData.emoji
            goal.labelBackgroundColor = iconData.backgroundColor
            goal.clockwise = (iconData.direction == .positive)
            goal.progress = CGFloat(iconData.progress)
            goal.progressColor = iconData.progressColor
            
        case .award(let awardData):
            award.isHidden = false
            goal.isHidden = true
            award.labelText = awardData.emoji
            award.labelBackgroundColor = awardData.backgroundColor
            award.borderColor = awardData.borderColor
        }

        totalLabel.text = "\(data.count)"
        streakLabel.text = "\(data.streak)"
        refreshCounters(sortOrder: sortOrder)
    }
    
    func refreshCounters(sortOrder: GoalStreakSortOrder) {

        // Primary counter that is used to sort will be drawn using
        // tintColor as background and bright text,
        // secondary counter will be on lighter background and actually put behind in z-order
        switch sortOrder {
        case .totalCount:
            totalLabel.backgroundColor = Theme.main.colors.tint
            totalLabel.textColor = Theme.main.colors.background
            streakLabel.backgroundColor = Theme.main.colors.secondaryBackground
            streakLabel.textColor = Theme.main.colors.text
            totalLabel.layer.zPosition = 2
            streakLabel.layer.zPosition = 1
            
        case .streakLength:
            streakLabel.backgroundColor = Theme.main.colors.tint
            streakLabel.textColor = Theme.main.colors.background
            totalLabel.backgroundColor = Theme.main.colors.secondaryBackground
            totalLabel.textColor = Theme.main.colors.text
            streakLabel.layer.zPosition = 2
            totalLabel.layer.zPosition = 1
        }
    }
    
    // MARK: - Private helpers
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        if totalLabel.frame.contains(sender.location(in: self)) {
            onCounterTapped?()
        } else if streakLabel.frame.contains(sender.location(in: self)) {
            onCounterTapped?()
        }
    }

    func setupViews() {
        goal.progressLineWidth = Theme.main.specs.progressWidthSmall
        goal.progressLineGap = Theme.main.specs.progressGapSmall
        award.borderWidth = Theme.main.specs.progressWidthSmall

        totalLabel.font = Theme.main.fonts.statsNumbers
        totalLabel.contentInsets = Specs.counterContentInsets
        totalLabel.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        totalLabel.clipsToBounds = true

        streakLabel.font = Theme.main.fonts.statsNumbers
        streakLabel.contentInsets = Specs.counterContentInsets
        streakLabel.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        streakLabel.clipsToBounds = true
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Total and streak counters content insets
    static let counterContentInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
    
    /// Stat squares line width
    static let lineWidth: CGFloat = 2.0

    ///
    static let valueLabelGap: CGFloat = 5.0

    /// Stat squares corner radius
    static let cornerRadius: CGFloat = 2.0

    /// Shadow radius
    static let shadowRadius: CGFloat = 2.0
    
    /// Shadow opacity
    static let shadowOpacity: Float = 0.4
    
    /// Shadow offset
    static let shadowOffset = CGSize(width: 0, height: 1)
}
