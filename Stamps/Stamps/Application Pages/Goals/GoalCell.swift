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
    @IBOutlet weak var progress: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()

        count.layer.cornerRadius = count.font.pointSize * 0.6
        count.clipsToBounds = true
        progress.layer.cornerRadius = progress.bounds.height / 2.0
        progress.clipsToBounds = true
    }
    
    func configureWith(_ goal: Goal, currentProgress: Int) {
        name.text = goal.name.isEmpty ? "-" : goal.name
        subtitle.text = goal.details
        
        if goal.count > 0 {
            count.text = "  \(goal.count)  "
            count.isHidden = false
        }
        else {
            count.isHidden = true
        }
        
        if goal.direction == .positive {
            if currentProgress >= goal.limit {
                progress.progress = 1.0
                progress.tintColor = UIColor.positiveGoalReached
            }
            else {
                progress.progress = Float(currentProgress) / Float(goal.limit)
                progress.tintColor = UIColor.positiveGoalNotReached
            }
        }
        else /* goal.direction == .negative */ {
            if currentProgress >= goal.limit {
                progress.progress = 1.0
                progress.tintColor = UIColor.negativeGoalReached
            }
            else {
                progress.progress = Float(currentProgress) / Float(goal.limit)
                progress.tintColor = UIColor.negativeGoalNotReached
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

