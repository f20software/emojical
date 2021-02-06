//
//  DayHeaderCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/05/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayHeaderCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var dayPlate: UIView!
    @IBOutlet weak var dayNum: UILabel!
    @IBOutlet weak var dayName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: DayHeaderData) {
        dayNum.text = data.dayNum
        dayName.text = data.dayName
        
        if data.isHighlighted {
            dayPlate.backgroundColor = data.isToday ?
                Theme.main.colors.calendarTodayBackground :
                Theme.main.colors.calendarHighlightedBackground
            
            // TODO: Review? - seems arbitrary
            dayNum.textColor = UIColor.white
            dayName.textColor = UIColor.white
        } else {
            dayPlate.backgroundColor = Theme.main.colors.secondaryBackground
            dayNum.textColor = data.isWeekend ?
                Theme.main.colors.weekendText :
                Theme.main.colors.text
            
            dayName.textColor = data.isWeekend ?
                Theme.main.colors.weekendText :
                Theme.main.colors.text
        }
    }

    // MARK: - Private helpers

    private func configureViews() {
        dayPlate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        dayPlate.clipsToBounds = true
    }
}
