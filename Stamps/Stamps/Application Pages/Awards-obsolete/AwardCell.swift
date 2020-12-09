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
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var awardIcon: AwardView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWith(_ award: Award, goal: Goal) {
        
        name.text = "\'\(goal.name)\' goal is reached."
        // subtitle.text = "\(goal.periodText). \(award.earnedOnText)"
        
        let color = Storage.shared.repository.colorForAward(award)
        let style = (goal.period == .week) ? 7 : 0
        awardIcon.backgroundColor = UIColor.clear
        awardIcon.configure(color: color, dashes: style)
        
        let date = award.date
        let df = DateFormatter()
        
        df.dateFormat = "d"
        day.text = df.string(from: date)
        
        df.dateFormat = "E"
        weekDay.text = df.string(from: date)
        
        if date.isWeekend {
            day.textColor = UIColor.systemRed
            weekDay.textColor = UIColor.systemRed
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        day.textColor = UIColor.label
        weekDay.textColor = UIColor.secondaryLabel
    }
}

