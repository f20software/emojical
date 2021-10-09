//
//  MonthBoxCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MonthBoxCell: ThemeObservingCollectionCell {

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
    // Dots view could have different width/height ratio based on the number of weeks in a month
    @IBOutlet weak var dotsHeight: NSLayoutConstraint!

    // Convinience array
    private var days: [UILabel] = []

    // Height / width ratio based on number of weeks
    private var weeksRatio: CGFloat = 5.0 / 7.0
    
    // We're loading data asynchroniously. To make sure that same cell is still used,
    // when data is retrieved - store asyncKey and check it when callback is returned
    private var asyncKey: UUID?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sticker.text = nil
        sticker.color = UIColor.clear
        asyncKey = nil
    }
    
    // MARK: - Public view interface
    
    func configure(for data: MonthBoxData,
        getData: ((_ completion: @escaping (UUID, String) -> Void) -> Void))
    {
        sticker.text = data.label
        sticker.color = data.color
        
        header.text = data.name
        
        for (text, label) in zip(data.weekdayHeaders, days) {
            label.text = text
        }

        dots.data = data.bitsAsString
        dots.startOffset = data.firstDayOffset
        weeksRatio = CGFloat(data.numberOfWeeks) / 7.0
        setNeedsLayout()

        // asyncKey - to make sure when completion block is called, cell that asked for this data
        // is still a cell that's receiving it
        asyncKey = data.primaryKey
        // Load month data async
        getData { [weak self] (asyncKey, bits) in
            guard asyncKey == self?.asyncKey else { return }

            self?.dots.data = bits
            DispatchQueue.main.async {
                self?.dots.setNeedsDisplay()
            }
        }
    }
    
    // MARK: - Private helpers
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: UILayoutPriority.required,
            verticalFittingPriority: UILayoutPriority.defaultLow
        )
        let autoLayoutFrame = CGRect(
            origin: autoLayoutAttributes.frame.origin,
            size: autoLayoutSize
        )
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func setupViews() {
        dots.lineWidth = Specs.lineWidth
        dots.cornerRadius = Specs.cornerRadius
        dots.boxesRatio = Specs.boxesRatio
        dots.backgroundColor = UIColor.clear
        
        border.backgroundColor = UIColor.clear
        border.layer.borderWidth = Specs.borderWidth
        border.layer.cornerRadius = Theme.main.specs.platesCornerRadius

        days = [day0, day1, day2, day3, day4, day5, day6]
        for day in days {
            day.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
            day.backgroundColor = Theme.main.colors.background
            day.textColor = Theme.main.colors.secondaryText
        }
        header.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        updateColors()
    }
    
    override func updateColors() {
        border.layer.borderColor = Theme.main.colors.separator.cgColor
    }
    
    override func layoutSubviews() {
        dotsHeight.constant = dots.bounds.width * weeksRatio
        super.layoutSubviews()
        dots.setNeedsDisplay()
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
}
