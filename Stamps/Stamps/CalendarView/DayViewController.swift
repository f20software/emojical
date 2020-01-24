//
//  DayViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayViewController : UIViewController {
    
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var stamp1: UILabel!
    @IBOutlet weak var stamp2: UILabel!
    @IBOutlet weak var stamp3: UILabel!
    @IBOutlet weak var stamp4: UILabel!
    @IBOutlet weak var stamp5: UILabel!
    
    var calendar: CalenderHelper {
        return CalenderHelper.shared
    }
    
    var db: DataSource {
        return DataSource.shared
    }

    var date: DateYMD? {
        didSet {
            guard let date = date else { return }
            
            dayTitle.text = "\(calendar.labelForDay(date))"
            currentStamps = db.stampsForDay(date)
            dataChanged = false
            
            for i in 0..<stampLabels.count {
                stampLabels[i].textColor = i < favs.count ?
                    (currentStamps.contains(favs[i].id) ? favs[i].color : UIColor.lightGray) : UIColor.clear
            }
        }
    }

    var onDismiss:(Bool) -> Void = { _ in }
    
    // Current stamps selected for the day
    var currentStamps = [Int]()
    // Flag indicating whether we need to refresh table underneath when dismissing day view
    var dataChanged = false

    // List of favorites stamps loaded from the DB
    var favs = [Stamp]()

    // Combine all UILabels into single array for easy access
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
    
    func toggleStamp(_ i: Int) {
        guard i < favs.count else { return }
        
        let stampId = favs[i].id
        
        if currentStamps.contains(stampId) {
            currentStamps.removeAll { $0 == stampId }
            stampLabels[i].textColor = UIColor.lightGray
        }
        else {
            currentStamps.append(stampId)
            stampLabels[i].textColor = favs[i].color
        }
        dataChanged = true
        stampLabels[i].setNeedsDisplay()
    }

    func dismissDayView() {
        if date != nil {
            // Order of items in currentStamps will reflect order in
            // which items were tapped. To ensure same order for all
            // days representation - let's order them before saving to the DB
            var cleanResult = [Int]()
            for st in favs {
                if currentStamps.contains(st.id) {
                    cleanResult.append(st.id)
                }
            }
            
            db.setStampsForDay(date!, stamps: cleanResult)
        }
        
        dismiss(animated: true) {
            self.onDismiss(self.dataChanged)
        }
    }
    
    @objc func dayViewTapped(sender: UITapGestureRecognizer) {
        
        // Tapped outside?
        if dayView.bounds.contains(sender.location(in: dayView)) == false {
            dismissDayView()
            return
        }
        
        // Check if we tapped on one of the stamps
        for i in 0..<stampLabels.count {
            if stampLabels[i].bounds.contains(sender.location(in: stampLabels[i])) {
                toggleStamp(i)
            }
        }
    }
}
