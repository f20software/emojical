//
//  YearBoxCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class YearBoxCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var dots: YearBoxView!
    
    @IBOutlet weak var header: UILabel!

//    @IBOutlet weak var day0: UILabel!
//    @IBOutlet weak var day1: UILabel!
//    @IBOutlet weak var day2: UILabel!
//    @IBOutlet weak var day3: UILabel!
//    @IBOutlet weak var day4: UILabel!
//    @IBOutlet weak var day5: UILabel!
//    @IBOutlet weak var day6: UILabel!

    @IBOutlet weak var dots54weeks: NSLayoutConstraint!
    @IBOutlet weak var dots53weeks: NSLayoutConstraint!

    // Convinience array
    private var days: [UILabel] = []
    
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
    
    func configure(for data: YearBoxData,
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
        // Hacky? Sure... - can't change ratio constant in run-time
        // https://stackoverflow.com/questions/19593641/can-i-change-multiplier-property-for-nslayoutconstraint
        dots54weeks.isActive = data.numberOfWeeks == 54
        dots53weeks.isActive = data.numberOfWeeks == 53

        dots.setNeedsLayout()
        dots.setNeedsDisplay()

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
    
    func setupViews() {
        dots.backgroundColor = UIColor.clear
        dots.lineWidth = Specs.lineWidth
        dots.cornerRadius = Specs.cornerRadius
        dots.boxesRatio = Specs.boxesRatio
        
//        days = [day0, day1, day2, day3, day4, day5, day6]
//        for day in days {
//            day.backgroundColor = UIColor.clear
//            day.textColor = UIColor.gray
//            day.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
//        }
        header.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Stat squares line width
    static let lineWidth: CGFloat = 1.0

    /// Stat squares corner radius
    static let cornerRadius: CGFloat = 1.0
    
    /// Boxes ratio (1.0 - no gaps between boxes)
    static let boxesRatio: CGFloat = 0.7

    /// Border width
    static let borderWidth: CGFloat = 1.0
    
    /// Border corner radius
    static let borderCornerRadius: CGFloat = 8.0
}
