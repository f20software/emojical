//
//  WeekLineCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class WeekLineCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var sticker: StickerView!
    @IBOutlet weak var dots: WeekLineView!
    @IBOutlet weak var separator: UIView!

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
    
    func configure(for data: WeekLineData) {
        sticker.text = data.label
        sticker.color = data.color
        
        dots.data = data.bitsAsString
        dots.setNeedsDisplay()
    }
    
    // MARK: - Private helpers
    
    func setupViews() {
        dots.backgroundColor = UIColor.clear
        // dots.tintColor = UIColor.darkGray
        dots.lineWidth = Specs.lineWidth
        dots.cornerRadius = Specs.cornerRadius
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Stat squares line width
    static let lineWidth: CGFloat = 2.0

    /// Stat squares corner radius
    static let cornerRadius: CGFloat = 2.0
}
