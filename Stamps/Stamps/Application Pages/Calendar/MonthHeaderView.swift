//
//  MonthHeaderView.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/19/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class MonthHeaderView: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var badges: MonthBadgeView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

