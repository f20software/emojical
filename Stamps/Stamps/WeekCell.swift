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
        mon.text = data[0]
        tue.text = data[1]
        wed.text = data[2]
        thu.text = data[3]
        fri.text = data[4]
        sat.text = data[5]
        sun.text = data[6]
    }
    
    override func prepareForReuse() {
        for label in [mon, tue, wed, thu, fri, sat, sun] {
            label!.text = nil
        }
    }
    
}

