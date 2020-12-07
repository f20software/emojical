//
//  DayStampCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/6/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayStampCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // backgroundColor = UIColor.red
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sticker.text = nil
        sticker.color = UIColor.clear
        sticker.isEnabled = true
    }
    
    // MARK: - Public view interface
    
    func configure(for data: DayStampData, insets: UIEdgeInsets) {
        // print("CONFIGURE \(self), \(data.label)")
        sticker.text = data.label
        sticker.color = data.color
        sticker.isEnabled = data.isEnabled
        tag = Int(data.stampId ?? 0)
        
        // Sticker insets
        topMargin.constant = insets.top
        bottomMargin.constant = insets.bottom
        leftMargin.constant = insets.left
        rightMargin.constant = insets.right
    }
}
