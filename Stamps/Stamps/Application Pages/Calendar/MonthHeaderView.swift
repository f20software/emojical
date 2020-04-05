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
    @IBOutlet weak var awards: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String, monthlyAwards: [UIColor], weeklyAwards: [UIColor]) {

        self.title.text = title
        self.awards.backgroundColor = UIColor.clear
        
        var x: CGFloat = 0
        let size = awards.bounds.height
        for color in monthlyAwards {
            let award = AwardView(frame: CGRect(x: x, y: 0, width: size, height: size))
            award.configure(color: color, dashes: 0)
            awards.addSubview(award)
            x += (size + 5)
        }
        for color in weeklyAwards {
            let award = AwardView(frame: CGRect(x: x, y: 0, width: size, height: size))
            award.configure(color: color, dashes: 7)
            awards.addSubview(award)
            x += (size + 5)
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for view in awards.subviews {
            view.removeFromSuperview()
        }
    }
    
}

