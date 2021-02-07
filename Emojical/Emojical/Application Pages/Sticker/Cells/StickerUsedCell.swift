//
//  StickerUsedCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/7/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerUsedCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var statistics: UILabel!
    @IBOutlet weak var average: UILabel!

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
                    .font: Theme.main.fonts.listBody,
                    .foregroundColor: Theme.main.colors.secondaryText,
                    .paragraphStyle: parStyle
                ])
            )
        }
        
        if lines.count > 1 {
            string.append(NSAttributedString(
                string: lines[1],
                attributes: [
                    .font: Theme.main.fonts.largeStats,
                    .foregroundColor: Theme.main.colors.text,
                    .paragraphStyle: parStyle
                ])
            )
        }
        
        if lines.count > 2 {
            string.append(NSAttributedString(
                string: "\n\(lines[2])",
                attributes: [
                    .font: Theme.main.fonts.listBody,
                    .foregroundColor: Theme.main.colors.secondaryText
                ])
            )
        }
        
        return string
    }
    
    func configure(for data: StickerUsedData) {
        statistics.attributedText = threeLinesDescription(
            Language.stickerUsageDescription(
                data.count, lastUsed: data.lastUsed).components(separatedBy: "|"))
        
        let formatted = (data.average > 0) ?
            String(format: "%.1f", data.average) :
            "-"
        
        average.attributedText = threeLinesDescription(
            ["On average", formatted, data.averagePeriod]
//            Language.goalStreakDescription(data.streak).components(separatedBy: "|")
        )
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = Theme.main.colors.secondaryBackground
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.clipsToBounds = true
    }
}
