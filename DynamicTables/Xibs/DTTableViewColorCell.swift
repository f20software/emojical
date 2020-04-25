//
//  DTTableViewColorCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/19/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

protocol DTTableViewColorCellDelegate {
    func colorSelected(_ colorIdx: Int)
}

class DTTableViewColorCell: UITableViewCell {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var color0: UIView!
    @IBOutlet var color1: UIView!
    @IBOutlet var color2: UIView!
    @IBOutlet var color3: UIView!
    @IBOutlet var color4: UIView!
    @IBOutlet var color5: UIView!
    @IBOutlet var color6: UIView!

    var delegate: DTTableViewColorCellDelegate?
    var selectedIndex = -1
    var allColorViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tap)
        
        selectionStyle = .none
        
        allColorViews = [color0, color1, color2, color3, color4, color5, color6]
        configureViews()
    }
    
    func setSelectedIndex(_ index: Int) {
        if selectedIndex >= 0 {
            allColorViews[selectedIndex].layer.borderWidth = 0.0
        }
     
        allColorViews[index].layer.borderWidth = 3.0
        selectedIndex = index
    }

    func configureViews() {
        // Round corners will not be visible anywhere but on today's day
        for view in allColorViews {
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
            view.backgroundColor = UIColor.systemBackground
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 0.0
        }
    }
    
    func setColors(_ colors: [String], selectedIdx: Int) {
        for i in 0..<allColorViews.count {
            allColorViews[i].backgroundColor = UIColor(hex: colors[i])
        }
        
        if selectedIndex >= 0 {
            setSelectedIndex(selectedIndex)
        }
    }
    
    override func prepareForReuse() {
        configureViews()
    }
    
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: self.stackView)
        let index = Int(ceil(loc.x / (self.stackView.frame.width / 7))) - 1
        
        if index >= 0 && index < 7 {
            delegate?.colorSelected(index)
            setSelectedIndex(index)
        }
    }
}

