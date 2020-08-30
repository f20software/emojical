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
    
    private var model: [CalendarCellData] = []
    private var favs = [Stamp]()

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Private helpers
    private func configureViews() {
        //
        dayViews = [day0view, day1view, day2view, day3view, day4view, day5view, day6view]
        dayNums = [day0num, day1num, day2num, day3num, day4num, day5num, day6num]
        dayLabels = [day0day, day1day, day2day, day3day, day4day, day5day, day6day]
        stamps = [stamp0, stamp1, stamp2, stamp3, stamp4, stamp5, stamp6, stamp7, stamp8, stamp9]
        
        for view in dayViews {
            view.layer.cornerRadius = 10.0
            view.clipsToBounds = true
            view.backgroundColor = UIColor.systemGray6
        }
        
        stampsPlate.layer.cornerRadius = 5.0
        stampsPlate.clipsToBounds = true
        stampsPlate.backgroundColor = UIColor.systemGray6
    }
    
    private func prepareData() {
        model = CalendarDataBuilder(repository: repository, calendar: calendar).cells(forStyle: .today)[0]
    }
    
    private func setTodayLabelStyle(labels: [UILabel], background: UIView) {
        for l in labels {
            l.textColor = UIColor.white
            l.backgroundColor = UIColor.red
        }
        background.backgroundColor = UIColor.red
    }

    private func loadDayLabels(_ labels: [String]) {
        for i in 0..<7 {
            if labels[i].starts(with: "*") {
                dayNums[i].text = labels[i].trimmingCharacters(in: CharacterSet(charactersIn: "*"))
                setTodayLabelStyle(labels: [dayLabels[i], dayNums[i]], background: dayViews[i])
            } else {
                dayNums[i].text = labels[i]
            }
        }
    }
    
    private func createStampViews(data: [[StickerData]]) {
        let margin: CGFloat = 8.0
        
        for i in 0..<7 {
            let dayStickers = data[i]
            
            let origin = dayViews[i].convert(CGPoint.zero, to: view)
            
            let x = origin.x + 4 // dayViews[i].bounds.origin.x
            var y = origin.y + dayViews[i].bounds.size.height + margin
            let width = dayViews[i].bounds.size.width - 8
            
            for sticker in dayStickers {
                let stickerView = StickerView(
                    frame: CGRect(
                        x: x,
                        y: y,
                        width: width,
                        height: width
                    )
                )
                
                y = y + width + margin
                
                stickerView.backgroundColor = UIColor.systemBackground
                stickerView.text = sticker.label
                stickerView.color = sticker.color
                view.addSubview(stickerView)
            }
        }
    }
    
    
    private func loadData() {
        for cellData in model {
            switch cellData {
            case let .header(title, monthlyAwards, weeklyAwards):
                self.title = title
                break
            case let .expandedWeek(labels, data, awards):
                loadDayLabels(labels)
                createStampViews(data: data)
                break
            default:
                break
            }
        }
        
        // Disabling showing only favorite stamps for now
        favs = repository.allStamps() // db.favoriteStamps()
        for i in 0..<stamps.count  {
            stamps[i].text = i < favs.count ? favs[i].label : ""
            stamps[i].color = i < favs.count ? favs[i].color : nil
        }
    }
}
