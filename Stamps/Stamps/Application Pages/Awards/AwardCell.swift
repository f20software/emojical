//
//  GoalCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/26/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class AwardCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var awardIcon: AwardView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWith(_ award: Award, goal: Goal) {
        
        name.text = goal.name
        subtitle.text = "\(goal.periodText). \(award.earnedOnText)"
        
        let color = DataSource.shared.colorForAward(award)
        let style = (goal.period == .week) ? 7 : 0
        awardIcon.backgroundColor = UIColor.clear
        awardIcon.configure(color: color, dashes: style)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

