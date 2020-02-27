//
//  GoalCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/26/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var count: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        count.layer.cornerRadius = count.font.pointSize * 0.6
        count.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

