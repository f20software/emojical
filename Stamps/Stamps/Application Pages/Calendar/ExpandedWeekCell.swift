//
//  WeekCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/19/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

protocol ExpandedWeekCellDelegate {
    // Index of the day tapped - from 0 to 6
    func dayTapped(_ dayIdx: Int, indexPath: IndexPath)
}

class ExpandedWeekCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var mon: UILabel!
    @IBOutlet weak var tue: UILabel!
    @IBOutlet weak var wed: UILabel!
    @IBOutlet weak var thu: UILabel!
    @IBOutlet weak var fri: UILabel!
    @IBOutlet weak var sat: UILabel!
    @IBOutlet weak var sun: UILabel!

    @IBOutlet weak var monStickersView: UIStackView!
    @IBOutlet weak var tueStickersView: UIStackView!
    @IBOutlet weak var wedStickersView: UIStackView!
    @IBOutlet weak var thuStickersView: UIStackView!
    @IBOutlet weak var friStickersView: UIStackView!
    @IBOutlet weak var satStickersView: UIStackView!
    @IBOutlet weak var sunStickersView: UIStackView!
    
    @IBOutlet weak var awardBadge: WeekBadgeView!
    
    var delegate: ExpandedWeekCellDelegate?
    var cellIndexPath: IndexPath?
    var allLabelsBadges: [(UILabel, UIStackView)]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tap)
        
        selectionStyle = .none
        contentView.backgroundColor = UIColor.systemBackground
        
        allLabelsBadges = [
            (mon, monStickersView),
            (tue, tueStickersView),
            (wed, wedStickersView),
            (thu, thuStickersView),
            (fri, friStickersView),
            (sat, satStickersView),
            (sun, sunStickersView)
        ]

        configureLabels()
    }
    
    func configureLabels() {
        // Round corners will not be visible anywhere but on today's day
        for (label, _) in allLabelsBadges {
            label.layer.cornerRadius = 6
            label.clipsToBounds = true
            label.textColor = UIColor.label
            label.backgroundColor = UIColor.systemBackground
        }

        if CalenderHelper.weekStartMonday {
            sat.textColor = UIColor.secondaryLabel
            sun.textColor = UIColor.secondaryLabel
        }
        else {
            mon.textColor = UIColor.secondaryLabel
            sun.textColor = UIColor.secondaryLabel
        }
    }
    
    func setTodayLabelStyle(label: UILabel) {
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.red
    }
    
    func configure(_ labels: [String], data: [[StickerData]], awards: [UIColor], indexPath: IndexPath) {
        for (_, badge) in allLabelsBadges {
            for view in badge.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
        
        for (index, views) in allLabelsBadges.enumerated() {
            let (label, badgeView) = views
            
            if labels[index].starts(with: "*") {
                label.text = labels[index].trimmingCharacters(in: CharacterSet(charactersIn: "*"))
                setTodayLabelStyle(label: label)
            } else {
                label.text = labels[index]
            }
            
            for sticker in data[index] {
                let stickerView = StickerView(frame: CGRect(x: 0, y: 0, width: Specs.stickerSide, height: Specs.stickerSide))
                stickerView.heightAnchor.constraint(equalToConstant: Specs.stickerSide).isActive = true
                stickerView.widthAnchor.constraint(equalToConstant: Specs.stickerSide).isActive = true
                stickerView.text = sticker.label
                stickerView.color = sticker.color
                
                badgeView.addArrangedSubview(stickerView)
            }
        }
        awardBadge.badges = awards
        self.cellIndexPath = indexPath
    }
    
    override func prepareForReuse() {
        for (label, _) in allLabelsBadges {
            label.text = nil
        }
        awardBadge.badges = nil
        awardBadge.setNeedsDisplay()
        configureLabels()
    }
    
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: self.stackView)
        let index = Int(ceil(loc.x / (self.stackView.frame.width / 7))) - 1
        
        if index >= 0 && index < 7 {
            delegate?.dayTapped(index, indexPath: cellIndexPath!)
        }
    }
    
    // MARK: - Sizes
    
    private struct Specs {
        static let stickerSide: CGFloat = 30
    }
}

