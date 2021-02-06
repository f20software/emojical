//
//  GoalDetailsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalReachedCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var statistics: UILabel!
    @IBOutlet weak var streak: UILabel!

    // MARK: - State

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }

    // MARK: - Public view interface

    private func threeLinesDescription(_ lines: [String]) -> NSAttributedString {
        
        let parStyle = NSMutableParagraphStyle()
        parStyle.lineSpacing = 5.0
        parStyle.alignment = .center
        let string = NSMutableAttributedString()
        
        if lines.count > 0 {
            string.append(NSAttributedString(
                string: "\(lines[0])\n",
                attributes: [
                    .font: Theme.shared.fonts.listBody,
                    .foregroundColor: Theme.shared.colors.secondaryText,
                    .paragraphStyle: parStyle
                ])
            )
        }
        
        if lines.count > 1 {
            string.append(NSAttributedString(
                string: lines[1],
                attributes: [
                    .font: Theme.shared.fonts.largeStats,
                    .foregroundColor: Theme.shared.colors.text,
                    .paragraphStyle: parStyle
                ])
            )
        }
        
        if lines.count > 2 {
            string.append(NSAttributedString(
                string: "\n\(lines[2])",
                attributes: [
                    .font: Theme.shared.fonts.listBody,
                    .foregroundColor: Theme.shared.colors.secondaryText
                ])
            )
        }
        
        return string
    }
    
    func configure(for data: GoalReachedData) {
        statistics.attributedText = threeLinesDescription(
            Language.goalReachedDescription(data.count, lastUsed: data.lastUsed).components(separatedBy: "|"))
        
        streak.attributedText = threeLinesDescription(
            Language.goalStreakDescription(data.streak).components(separatedBy: "|")
        )
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = Theme.shared.colors.secondaryBackground
        plate.layer.cornerRadius = Theme.shared.specs.platesCornerRadius
        plate.clipsToBounds = true
    }
}
