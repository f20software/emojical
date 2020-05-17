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

/// Week cell with all stamps shown below each day.
class ExpandedWeekCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var dayLabels: [UILabel]!
    @IBOutlet var stickersViews: [UIStackView]!
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var sunLabel: UILabel!
    @IBOutlet weak var satLabel: UILabel!
    @IBOutlet weak var awardBadge: WeekBadgeView!
    
    // MARK: - Properties
    
    var delegate: ExpandedWeekCellDelegate?
    var cellIndexPath: IndexPath?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tap)
        
        selectionStyle = .none
        contentView.backgroundColor = UIColor.systemBackground
        
        configureLabels()
    }
    
    func configureLabels() {
        // Round corners will not be visible anywhere but on today's day
        for label in dayLabels {
            label.layer.cornerRadius = 6
            label.clipsToBounds = true
            label.textColor = UIColor.label
            label.backgroundColor = UIColor.systemBackground
        }

        if CalenderHelper.weekStartMonday {
            satLabel.textColor = UIColor.secondaryLabel
            sunLabel.textColor = UIColor.secondaryLabel
        } else {
            monLabel.textColor = UIColor.secondaryLabel
            sunLabel.textColor = UIColor.secondaryLabel
        }
    }
    
    func setTodayLabelStyle(label: UILabel) {
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.red
    }
    
    func configure(_ labels: [String], data: [[StickerData]], awards: [UIColor], indexPath: IndexPath) {
        for stickersView in stickersViews {
            for view in stickersView.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
        
        for (index, views) in zip(dayLabels, stickersViews).enumerated() {
            let (label, badgeView) = views
            
            if labels[index].starts(with: "*") {
                label.text = labels[index].trimmingCharacters(in: CharacterSet(charactersIn: "*"))
                setTodayLabelStyle(label: label)
            } else {
                label.text = labels[index]
            }
            
            for sticker in data[index] {
                let stickerView = StickerView(
                    frame: CGRect(
                        x: 0,
                        y: 0,
                        width: Specs.stickerSide,
                        height: Specs.stickerSide
                    )
                )
                
                stickerView.translatesAutoresizingMaskIntoConstraints = false
                stickerView.heightAnchor.constraint(equalToConstant: Specs.stickerSide).isActive = true
                stickerView.widthAnchor.constraint(equalToConstant: Specs.stickerSide).isActive = true
                
                stickerView.backgroundColor = UIColor.systemBackground
                stickerView.text = sticker.label
                stickerView.color = sticker.color
                
                badgeView.addArrangedSubview(stickerView)
            }
        }
        awardBadge.badges = awards
        self.cellIndexPath = indexPath
    }
    
    override func prepareForReuse() {
        for label in dayLabels {
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

