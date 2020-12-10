//
//  MonthBoxCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MonthBoxCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var dots: MonthBoxView!
    @IBOutlet weak var border: UIView!
    
    @IBOutlet weak var header: UILabel!

    @IBOutlet weak var day0: UILabel!
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var day2: UILabel!
    @IBOutlet weak var day3: UILabel!
    @IBOutlet weak var day4: UILabel!
    @IBOutlet weak var day5: UILabel!
    @IBOutlet weak var day6: UILabel!

    @IBOutlet weak var dots4weeks: NSLayoutConstraint!
    @IBOutlet weak var dots5weeks: NSLayoutConstraint!
    @IBOutlet weak var dots6weeks: NSLayoutConstraint!

    // Convinience array
    private var days: [UILabel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        // self.backgroundColor = UIColor.red
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sticker.text = nil
        sticker.color = UIColor.clear
    }
    
    // MARK: - Public view interface
    
    func configure(for data: MonthBoxData) {
        sticker.text = data.label
        sticker.color = data.color
        
        header.text = data.name
        
        for (text, label) in zip(data.weekdayHeaders, days) {
            label.text = text
        }

        dots.data = data.bitsAsString
        dots.startOffset = data.firstDayOffset
        // Hacky? Sure... - can't change ratio constant in run-time
        // https://stackoverflow.com/questions/19593641/can-i-change-multiplier-property-for-nslayoutconstraint
        dots4weeks.isActive = data.numberOfWeeks == 4
        dots5weeks.isActive = data.numberOfWeeks == 5
        dots6weeks.isActive = data.numberOfWeeks == 6

        dots.setNeedsLayout()
        dots.setNeedsDisplay()
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        dots.backgroundColor = UIColor.clear
        dots.lineWidth = Specs.lineWidth
        dots.cornerRadius = Specs.cornerRadius
        dots.boxesRatio = Specs.boxesRatio
        
        border.backgroundColor = UIColor.clear
        border.layer.borderWidth = Specs.borderWidth
        border.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
        border.layer.cornerRadius = Specs.borderCornerRadius

        days = [day0, day1, day2, day3, day4, day5, day6]
        for day in days {
            day.backgroundColor = UIColor.clear
            day.textColor = UIColor.gray
            day.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        }
        header.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Stat squares line width
    static let lineWidth: CGFloat = 2.0

    /// Stat squares corner radius
    static let cornerRadius: CGFloat = 2.0
    
    /// Boxes ratio (1.0 - no gaps between boxes)
    static let boxesRatio: CGFloat = 0.7

    /// Border width
    static let borderWidth: CGFloat = 1.0
    
    /// Border corner radius
    static let borderCornerRadius: CGFloat = 8.0
}
