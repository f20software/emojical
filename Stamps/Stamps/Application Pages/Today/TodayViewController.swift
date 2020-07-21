//
//  CalendarViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

class TodayViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // Day views on the top
    @IBOutlet weak var day0view: UIView!
    @IBOutlet weak var day0num: UILabel!
    @IBOutlet weak var day0day: UILabel!
    @IBOutlet weak var day1view: UIView!
    @IBOutlet weak var day1num: UILabel!
    @IBOutlet weak var day1day: UILabel!
    @IBOutlet weak var day2view: UIView!
    @IBOutlet weak var day2num: UILabel!
    @IBOutlet weak var day2day: UILabel!
    @IBOutlet weak var day3view: UIView!
    @IBOutlet weak var day3num: UILabel!
    @IBOutlet weak var day3day: UILabel!
    @IBOutlet weak var day4view: UIView!
    @IBOutlet weak var day4num: UILabel!
    @IBOutlet weak var day4day: UILabel!
    @IBOutlet weak var day5view: UIView!
    @IBOutlet weak var day5num: UILabel!
    @IBOutlet weak var day5day: UILabel!
    @IBOutlet weak var day6view: UIView!
    @IBOutlet weak var day6num: UILabel!
    @IBOutlet weak var day6day: UILabel!
    
    // Reference arrays for easier access
    var dayViews: [UIView]!
    var dayNums: [UILabel]!
    var dayLabels: [UILabel]!
    
    // Stamps container
    @IBOutlet weak var stampsPlate: UIView!
    @IBOutlet weak var stamp0: StickerView!
    @IBOutlet weak var stamp1: StickerView!
    @IBOutlet weak var stamp2: StickerView!
    @IBOutlet weak var stamp3: StickerView!
    @IBOutlet weak var stamp4: StickerView!
    @IBOutlet weak var stamp5: StickerView!
    @IBOutlet weak var stamp6: StickerView!
    @IBOutlet weak var stamp7: StickerView!
    @IBOutlet weak var stamp8: StickerView!
    @IBOutlet weak var stamp9: StickerView!
    
    // Reference arrays for easier access
    var stamps: [StickerView]!
    
    // MARK: - Private state
    
    private var calendar: CalendarHelper {
        return CalendarHelper.shared
    }
    
    private var repository: DataRepository {
        return Storage.shared.repository
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayViews = [day0view, day1view, day2view, day3view, day4view, day5view, day6view]
        dayNums = [day0num, day1num, day2num, day3num, day4num, day5num, day6num]
        dayLabels = [day0day, day1day, day2day, day3day, day4day, day5day, day6day]
        stamps = [stamp0, stamp1, stamp2, stamp3, stamp4, stamp5, stamp6, stamp7, stamp8, stamp9]
    }
}
