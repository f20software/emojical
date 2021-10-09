//
//  GoalStatsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/04/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalStatsCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var goal: GoalIconView!
    @IBOutlet weak var award: AwardIconView!
    @IBOutlet weak var chart: GoalChartView!
    @IBOutlet weak var chartBackground: UIView!
    @IBOutlet weak var counter: UILabelWithContentInset!
    
    // MARK: - State
    
    // Counter label can show primary / secondary text
    // It uses different textColor/background style for them as well
    private var counterText: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface
    
    func configure(for data: GoalStats, chartCount: Int, primary: Bool) {
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

        counterText = [
            counterLabel(data.count),
            counterLabel(data.streak)
        ]
        
        refreshCounters(primary: primary)
        if let chartData = data.chart {
            chart.data = chartData.points
            chart.dataMax = chartData.points.map({ $0.total }).max() ?? 0
            chart.dataThreshold = chartData.points.first?.limit ?? 0
            chart.count = chartCount
        }
    }

    func refreshCounters(primary: Bool) {
        // Sanity check to make sure we stored both values
        guard counterText.count == 2 else { return }
        
        if primary {
            counter.backgroundColor = Theme.main.colors.tint
            counter.textColor = Theme.main.colors.background
            counter.layer.borderColor = UIColor.clear.cgColor
            counter.layer.borderWidth = 0.0
            counter.text = counterText[0]
        } else {
            counter.backgroundColor = Theme.main.colors.background
            counter.textColor = Theme.main.colors.tint
            counter.layer.borderColor = Theme.main.colors.tint.cgColor
            counter.layer.borderWidth = 2.0
            counter.text = counterText[1]
        }
    }
    
    // MARK: - Private helpers
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chart.setNeedsDisplay()
    }
    
    func setupViews() {
        goal.progressLineWidth = Theme.main.specs.progressWidthSmall
        goal.progressLineGap = Theme.main.specs.progressGapSmall
        award.borderWidth = Theme.main.specs.progressWidthSmall

        counter.font = Theme.main.fonts.statsNumbers
        counter.contentInsets = Specs.counterContentInsets
        counter.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        counter.clipsToBounds = true

        chart.backgroundColor = Theme.main.colors.secondaryBackground
        chart.lineColor = Theme.main.colors.tint
        chart.dotRadius = Specs.chartDotRadius
        chart.lineWidth = Specs.chartLineWidth

        chartBackground.backgroundColor = Theme.main.colors.secondaryBackground
        chartBackground.layer.cornerRadius = Specs.chartCornerRadius
        chartBackground.clipsToBounds = true
    }

    /// Formats nullable int value into text to display on the counter
    private func counterLabel(_ value: Int?) -> String {
        guard let value = value, value > 0 else {
            return "-"
        }
        return "\(value)"
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Total and streak counters content insets
    static let counterContentInsets = UIEdgeInsets.init(top: 3, left: 5, bottom: 3, right: 5)
    
    /// History chart line width
    static let chartLineWidth: CGFloat = 2.5

    /// History chart circle radius
    static let chartDotRadius: CGFloat = 4.5

    /// Stat squares corner radius
    static let chartCornerRadius: CGFloat = 5.0
}
