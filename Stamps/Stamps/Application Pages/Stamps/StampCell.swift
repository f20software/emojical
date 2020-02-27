//
//  StampCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/26/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StampCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        label.layer.cornerRadius = 20.0
        label.layer.borderWidth = 2.0
        label.clipsToBounds = true
        // count.backgroundColor = UIColor.red
        // count.textColor = UIColor.white
        count.layer.cornerRadius = count.font.pointSize * 0.6
        count.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

