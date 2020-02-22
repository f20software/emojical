//
//  WeekCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/19/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

protocol WeekCellDelegate {
    // Index of the day tapped - from 0 to 6
    func dayTapped(_ dayIdx: Int, indexPath: IndexPath)
}

class WeekCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var mon: UILabel!
    @IBOutlet weak var tue: UILabel!
    @IBOutlet weak var wed: UILabel!
    @IBOutlet weak var thu: UILabel!
    @IBOutlet weak var fri: UILabel!
    @IBOutlet weak var sat: UILabel!
    @IBOutlet weak var sun: UILabel!

    @IBOutlet weak var monBadge: DayBadgeView!
    @IBOutlet weak var tueBadge: DayBadgeView!
    @IBOutlet weak var wedBadge: DayBadgeView!
    @IBOutlet weak var thuBadge: DayBadgeView!
    @IBOutlet weak var friBadge: DayBadgeView!
    @IBOutlet weak var satBadge: DayBadgeView!
    @IBOutlet weak var sunBadge: DayBadgeView!
    
    @IBOutlet weak var awardBadge: AwardBadgeView!
    
    var delegate: WeekCellDelegate?
    var cellIndexPath: IndexPath?
    var allLabelsBadges: [(UILabel, DayBadgeView)]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tap)
        
        self.selectionStyle = .none
        allLabelsBadges = [
            (mon, monBadge),
            (tue, tueBadge),
            (wed, wedBadge),
            (thu, thuBadge),
            (fri, friBadge),
            (sat, satBadge),
            (sun, sunBadge)
        ]
        
        if CalenderHelper.weekStartMonday {
            sat.textColor = UIColor.secondaryLabel
            sun.textColor = UIColor.secondaryLabel
        }
        else {
            mon.textColor = UIColor.secondaryLabel
            sun.textColor = UIColor.secondaryLabel
        }
    }
    
    func loadData(_ labels: [String], data: [[UIColor]], awards: [UIColor], indexPath: IndexPath) {
        var idx = 0
        for (label, badgeView) in allLabelsBadges {
            label.text = labels[idx]
            badgeView.badges = data[idx]
            idx += 1
        }
        awardBadge.badges = awards
        self.cellIndexPath = indexPath
    }
    
    override func prepareForReuse() {
        for (label, badgeView) in allLabelsBadges {
            label.text = nil
            badgeView.badges = nil
            badgeView.setNeedsDisplay()
        }
        awardBadge.badges = nil
        awardBadge.setNeedsDisplay()
    }
    
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: self.stackView)
        let index = Int(ceil(loc.x / (self.stackView.frame.width / 7))) - 1
        
        if index >= 0 && index < 7 {
            delegate?.dayTapped(index, indexPath: cellIndexPath!)
        }
    }
}

