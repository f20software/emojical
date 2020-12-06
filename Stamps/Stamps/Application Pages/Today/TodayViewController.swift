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
    @IBOutlet weak var day0: DayColumnView!
    @IBOutlet weak var day1: DayColumnView!
    @IBOutlet weak var day2: DayColumnView!
    @IBOutlet weak var day3: DayColumnView!
    @IBOutlet weak var day4: DayColumnView!
    @IBOutlet weak var day5: DayColumnView!
    @IBOutlet weak var day6: DayColumnView!

    // Reference arrays for easier access
    var dayViews: [DayColumnView]!
    
    // Stamps container
    @IBOutlet weak var stampSelector: StampSelectorView!
    @IBOutlet weak var stampsPlate: UIView!
    // @IBOutlet weak var stamps: UICollectionView!
    
    // MARK: - Private state
    
    private var calendar: CalendarHelper {
        return CalendarHelper.shared
    }
    
    private var repository: DataRepository {
        return Storage.shared.repository
    }
    
    private var model: [DayColumnData] = []
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
        dayViews = [day0, day1, day2, day3, day4, day5, day6]
    }
    
    private func prepareData() {
        model = CalendarDataBuilder(repository: repository, calendar: calendar).weekDataForToday()
    }
    
    private func loadData() {
        guard model.count == 7 else { return }
        
        for (data, view) in zip(model, dayViews) {
            view.loadData(data: data)
        }
        
        let stamps = repository.allStamps()
        stampSelector.loadData(data:
            stamps.map({ StickerData(label: $0.label, color: $0.color )}))
    }
}
