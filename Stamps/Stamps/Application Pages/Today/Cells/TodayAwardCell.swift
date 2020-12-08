//
//  TodayAwardCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/7/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class TodayAwardCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var award: AwardView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        sticker.text = nil
//        sticker.color = UIColor.clear
//        sticker.isEnabled = true
    }
    
    // MARK: - Public view interface
    
    func configure(for data: TodayAwardData) {
        award.configure(color: data.color, dashes: data.dashes)
        
//        sticker.text = data.label
//        sticker.color = data.color
//        sticker.isEnabled = data.isEnabled
//        tag = Int(data.stampId ?? 0)
//        
//        // Sticker insets
//        topMargin.constant = insets.top
//        bottomMargin.constant = insets.bottom
//        leftMargin.constant = insets.left
//        rightMargin.constant = insets.right
    }
}
