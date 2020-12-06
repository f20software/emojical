//
//  DayHeaderCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 12/5/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayHeaderCell: UICollectionViewCell {

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
        
        dayNum.textColor = data.isWeekend ? UIColor.red : UIColor.label
        dayName.textColor = data.isWeekend ? UIColor.red : UIColor.label
        
        dayPlate.backgroundColor = data.isCurrent ? UIColor.systemGray3 : UIColor.systemGray6
    }

    // MARK: - Private helpers

    private func configureViews() {
        dayPlate.layer.cornerRadius = Specs.cornerRadius
        dayPlate.clipsToBounds = true
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0
}
