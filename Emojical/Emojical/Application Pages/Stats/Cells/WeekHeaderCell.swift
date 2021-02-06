//
//  WeekHeaderCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class WeekHeaderCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var day0: UILabel!
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var day2: UILabel!
    @IBOutlet weak var day3: UILabel!
    @IBOutlet weak var day4: UILabel!
    @IBOutlet weak var day5: UILabel!
    @IBOutlet weak var day6: UILabel!
    
    // MARK: - State
    
    // Convinience array
    private var days: [UILabel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public view interface
    
    func configure(for data: WeekHeaderData) {
        for (text, label) in zip(data.weekdayHeaders, days) {
            label.text = text
        }
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        days = [day0, day1, day2, day3, day4, day5, day6]
        for day in days {
            day.backgroundColor = UIColor.clear
            day.textColor = Theme.main.colors.secondaryText
            day.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
}
