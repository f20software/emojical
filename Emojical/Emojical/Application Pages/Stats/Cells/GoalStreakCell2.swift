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
    @IBOutlet weak var goalBackgroundView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalBar: UIView!
    @IBOutlet weak var totalLength: NSLayoutConstraint!
    @IBOutlet weak var totalLabelGap: NSLayoutConstraint!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var streakBar: UIView!
    @IBOutlet weak var streakLength: NSLayoutConstraint!
    @IBOutlet weak var streakLabelGap: NSLayoutConstraint!

    @IBOutlet weak var maxTotal: UIView!
    @IBOutlet weak var maxStreak: UIView!

    /// 
    var onCellTapped: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        totalLabelGap.constant = Specs.valueLabelGap
        totalLabel.textColor = Theme.main.colors.text
        streakLabelGap.constant = Specs.valueLabelGap
        streakLabel.textColor = Theme.main.colors.text
    }
    
    // MARK: - Private state
    
    private var total: Float = 1.0
    private var streak: Float = 1.0
    private var data: GoalStreakData2?
    
    let minValue: CGFloat = 10.0
    
    // MARK: - Public view interface
    
    func configure(for data: GoalStreakData2, maxTotal: Float, maxStreak: Float) {
        self.data = data
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
        totalLength.constant = minValue
        streakLabel.text = "\(data.streak)"
        streakLength.constant = minValue
        
        total = Float(data.count) / Float(maxTotal)
        streak = Float(data.streak) / Float(maxStreak)
    }
    
    
    // Animate progress on the goal icon from 0 to 1.0 and then show award icon
    func animateProgress() {

        var newTotalValue = maxTotal.bounds.width * CGFloat(total)
        if newTotalValue < minValue {
            newTotalValue = minValue
        }
        
        var newStreakValue = maxStreak.bounds.width * CGFloat(streak)
        if newStreakValue < minValue {
            newStreakValue = minValue
        }
        
        if (newTotalValue + totalLabel.bounds.width + Specs.valueLabelGap) > maxTotal.bounds.width {
            totalLabelGap.constant = -(totalLabel.bounds.width + Specs.valueLabelGap)
            totalLabel.textColor = Theme.main.colors.background
        } else {
            totalLabelGap.constant = Specs.valueLabelGap
            totalLabel.textColor = Theme.main.colors.text
        }
        
        if (newStreakValue + streakLabel.bounds.width + Specs.valueLabelGap) > maxStreak.bounds.width {
            streakLabelGap.constant = -(streakLabel.bounds.width + Specs.valueLabelGap)
            streakLabel.textColor = Theme.main.colors.background
        } else {
            streakLabelGap.constant = Specs.valueLabelGap
            streakLabel.textColor = Theme.main.colors.text
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0.0, options: [.curveLinear], animations:
        {
            self.totalLength.constant = newTotalValue
            self.streakLength.constant = newStreakValue

            self.layoutIfNeeded()
        })
    }

    
    // MARK: - Private helpers
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        if totalBar.bounds.contains(sender.location(in: totalBar)) {
            print("total")
            onCellTapped?(0)
        } else if award.bounds.contains(sender.location(in: award)) {
            print("award")
            onCellTapped?(1)
        } else if streakBar.bounds.contains(sender.location(in: streakBar)) {
            print("streak")
            onCellTapped?(2)
        }
    }

    func setupViews() {
        goal.progressLineWidth = Theme.main.specs.progressWidthSmall
        goal.progressLineGap = Theme.main.specs.progressGapSmall
        award.borderWidth = Theme.main.specs.progressWidthSmall

        totalBar.layer.cornerRadius = 5.0
        totalBar.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.5)
        totalBar.clipsToBounds = true
        
        streakBar.layer.cornerRadius = 5.0
        streakBar.backgroundColor = Theme.main.colors.tint
        streakBar.clipsToBounds = true
        
        totalLabel.font = Theme.main.fonts.statsNumbers
        streakLabel.font = Theme.main.fonts.statsNumbers

        goalBackgroundView.layer.cornerRadius = goalBackgroundView.bounds.width / 2.0
        // goalBackgroundView.clipsToBounds = true
        goalBackgroundView.backgroundColor = Theme.main.colors.background
        // goalBackgroundView.layer.borderWidth = 0.5
        // goalBackgroundView.layer.borderColor = Theme.main.colors.tint.withAlphaComponent(0.2).cgColor

        goalBackgroundView.layer.shadowRadius = Specs.shadowRadius
        goalBackgroundView.layer.shadowOpacity = Specs.shadowOpacity
        goalBackgroundView.layer.shadowColor = Theme.main.colors.shadow.cgColor
        goalBackgroundView.layer.shadowOffset = Specs.shadowOffset
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
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
