//
//  WeekCell.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/19/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class WeekCell: UITableViewCell {
    
    @IBOutlet weak var mon: UILabel!
    @IBOutlet weak var tue: UILabel!
    @IBOutlet weak var wed: UILabel!
    @IBOutlet weak var thu: UILabel!
    @IBOutlet weak var fri: UILabel!
    @IBOutlet weak var sat: UILabel!
    @IBOutlet weak var sun: UILabel!
    
    func loadData(_ data: [String]) {
        var idx = 0
        for label in [mon, tue, wed, thu, fri, sat, sun] {
            label!.text = data[idx]
            idx += 1
        }
    }
    
    override func prepareForReuse() {
        for label in [mon, tue, wed, thu, fri, sat, sun] {
            label!.text = nil
        }
    }
    
}

