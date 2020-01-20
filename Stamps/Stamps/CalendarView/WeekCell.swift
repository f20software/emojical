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
    func dayTapped(_ day: Int, indexPath: IndexPath)
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

    var delegate: WeekCellDelegate?
    var cellIndexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tap)
        
        self.selectionStyle = .none
    }
    
    func loadData(_ data: [String], indexPath: IndexPath) {
        var idx = 0
        for label in [mon, tue, wed, thu, fri, sat, sun] {
            label!.text = data[idx]
            idx += 1
        }
        self.cellIndexPath = indexPath
    }
    
    override func prepareForReuse() {
        for label in [mon, tue, wed, thu, fri, sat, sun] {
            label!.text = nil
        }
    }
    
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: self.stackView)
        let index = Int(ceil(loc.x / (self.stackView.frame.width / 7))) - 1
        
        if delegate != nil && index >= 0 && index < 7 {
            delegate!.dayTapped(index, indexPath: cellIndexPath!)
        }
    }
}

