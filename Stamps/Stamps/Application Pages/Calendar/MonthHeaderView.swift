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
    
    let db = DataSource.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.systemBackground
    }
    
    func configure(title: String, monthlyAwards: [Award], weeklyAwards: [Award]) {

        self.title.text = title
        self.awards.backgroundColor = UIColor.clear
        
        var x: CGFloat = 0
        let size = awards.bounds.height
        for award in monthlyAwards {
            let badge = AwardView(frame: CGRect(x: x, y: 0, width: size, height: size))
            badge.configure(color: db.colorForAward(award), dashes: 0)
            awards.addSubview(badge)
            x += (size + 5)
        }
        
        var lastGoalId: Int64 = -1
        for award in weeklyAwards {
            if award.goalId == lastGoalId {
                x -= (size / 1.5)
            }
            
            let badge = AwardView(frame: CGRect(x: x, y: 0, width: size, height: size))
            badge.configure(color: db.colorForAward(award), dashes: 7)
            badge.backgroundColor = UIColor.systemBackground // override background color since we will be overlapping them
            awards.addSubview(badge)
            lastGoalId = award.goalId
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

