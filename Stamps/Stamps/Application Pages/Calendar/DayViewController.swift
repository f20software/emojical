//
//  DayViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

class DayViewController : UIViewController {
    
    let notSelectedStampColor = UIColor(hex: "DDDDDD")
    
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var stamp1: StickerView!
    @IBOutlet weak var stamp2: StickerView!
    @IBOutlet weak var stamp3: StickerView!
    @IBOutlet weak var stamp4: StickerView!
    @IBOutlet weak var stamp5: StickerView!
    @IBOutlet weak var stamp6: StickerView!
    @IBOutlet weak var stamp7: StickerView!
    @IBOutlet weak var stamp8: StickerView!
    @IBOutlet weak var stamp9: StickerView!
    @IBOutlet weak var stamp10: StickerView!
    @IBOutlet weak var bottomDistance: NSLayoutConstraint!
    
    var locked: Bool = false
    
    var calendar: CalenderHelper {
        return CalenderHelper.shared
    }
    
    var db: DataSource {
        return DataSource.shared
    }

    var date: Date? {
        didSet {
            guard let date = date else { return }
            
            dayTitle.text = "\(calendar.labelForDay(date))"

            let untilToday = Int(date.timeIntervalSince(Date()) / (60*60*24))
            // Disable editing for dates more than 1 week in the past and 1 day in the future
            locked = untilToday < -6 || untilToday > 1
            lockButton.isHidden = !locked
            
            currentStamps = db.stampsIdsForDay(date)
            dataChanged = false

            // Based on whether we have 1 or 2 rows of stickers -
            // adjust bottom constraint to hide/show second one
            bottomDistance.constant = favs.count > 5 ? 15.0 : -45.0

            for i in 0..<stampLabels.count {
                stampLabels[i].alpha = (i >= favs.count) ? 0.0 : 1.0
                // stampLabels[i].isHidden = (i >= favs.count)
                if i < favs.count {
                    stampLabels[i].isEnabled = currentStamps.contains(favs[i].id!)
                }
            }
        }
    }

    var onDismiss:(Bool) -> Void = { _ in }
    
    // Current stamps selected for the day
    var currentStamps = [Int64]()
    // Flag indicating whether we need to refresh table underneath when dismissing day view
    var dataChanged = false

    // List of favorites stamps loaded from the DB
    var favs = [Stamp]()

    // Combine all EmojiViews into single array for easy access
    var stampLabels = [StickerView]()

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

        // Disabling showing only favorite stamps for now
        favs = db.allStamps() // db.favoriteStamps()
        stampLabels = [stamp1, stamp2, stamp3, stamp4, stamp5, stamp6, stamp7, stamp8, stamp9, stamp10]

        for i in 0..<stampLabels.count  {
            stampLabels[i].text = i < favs.count ? favs[i].label : ""
            stampLabels[i].color = i < favs.count ? UIColor(hex: favs[i].color) : nil
        }
    }
    
    func toggleStamp(_ i: Int) {
        guard i < favs.count else { return }
        
        let stampId = favs[i].id!
        
        if currentStamps.contains(stampId) {
            currentStamps.removeAll { $0 == stampId }
            stampLabels[i].isEnabled = false
        }
        else {
            currentStamps.append(stampId)
            stampLabels[i].isEnabled = true
        }
        dataChanged = true
        stampLabels[i].setNeedsDisplay()
    }

    func dismissDayView() {
        if date != nil {
            // Order of items in currentStamps will reflect order in
            // which items were tapped. To ensure same order for all
            // days representation - let's order them before saving to the DB
            var cleanResult = [Int64]()
            for st in favs {
                if currentStamps.contains(st.id!) {
                    cleanResult.append(st.id!)
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
        
        if locked {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
