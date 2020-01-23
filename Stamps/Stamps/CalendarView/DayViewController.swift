//
//  DayViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayViewController : UIViewController {
    
    var calendar: CalenderHelper {
        return CalenderHelper.shared
    }
    
    var db: DataSource {
        return DataSource.shared
    }

    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var stamp1: UILabel!
    @IBOutlet weak var stamp2: UILabel!
    @IBOutlet weak var stamp3: UILabel!
    @IBOutlet weak var stamp4: UILabel!
    @IBOutlet weak var stamp5: UILabel!
    
    var date: DateYMD? {
        didSet {
            guard let date = date else { return }
            
            dayTitle.text = "\(calendar.textForMonth(date.month)), \(date.day)"
            currentStamps = db.stampsForDay(date) ?? [Int]()
            
            for i in 0..<stampLabels.count {
                stampLabels[i].textColor = i < favs.count ?
                    (currentStamps.contains(favs[i].id) ? favs[i].color : UIColor.gray) : UIColor.clear
            }
        }
    }

    var onDismiss:(Bool) -> Void = { _ in }
    
    var currentStamps = [Int]()
    var favs = [Stamp]()
    var stampLabels = [UILabel]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dayViewTapped))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dayView.layer.cornerRadius = 5.0
        self.dayView.clipsToBounds = true
        // self.dayView.backgroundColor = UIColor.gray
        
        self.dayView.layer.borderColor = UIColor.darkGray.cgColor
        self.dayView.layer.borderWidth = 0.5

        favs = db.favoriteStamps()
        stampLabels = [stamp1, stamp2, stamp3, stamp4, stamp5]

        for i in 0..<stampLabels.count  {
            stampLabels[i].text = i < favs.count ? favs[i].label : ""
        }
    }

    @objc func dayViewTapped(sender: UITapGestureRecognizer) {
        
        // Tapped outside?
        let loc = sender.location(in: self.dayView)
        if self.dayView.bounds.contains(loc) == false {
            self.dismiss(animated: true) {
                self.db.setStampsForDay(self.date!, stamps: self.currentStamps)
                self.onDismiss(true)
            }
        }
        
        // Check if we tapped on one of the stamps
        for i in 0..<stampLabels.count {
            if stampLabels[i].bounds.contains(sender.location(in: stampLabels[i])) {
                guard i < favs.count else { return }
                
                if currentStamps.contains(favs[i].id) {
                    currentStamps.removeAll { $0 == favs[i].id }
                    stampLabels[i].textColor = UIColor.gray
                }
                else {
                    currentStamps.append(favs[i].id)
                    stampLabels[i].textColor = favs[i].color
                }
                stampLabels[i].setNeedsDisplay()
            }
        }
    }
}
