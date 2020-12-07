//
//  CalendarViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

class TodayViewController: UIViewController, TodayView {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var day0: DayColumnView!
    @IBOutlet weak var day1: DayColumnView!
    @IBOutlet weak var day2: DayColumnView!
    @IBOutlet weak var day3: DayColumnView!
    @IBOutlet weak var day4: DayColumnView!
    @IBOutlet weak var day5: DayColumnView!
    @IBOutlet weak var day6: DayColumnView!
    @IBOutlet weak var stampSelector: StampSelectorView!

    // MARK: - DI

    var presenter: TodayPresenterProtocol!

    // Reference arrays for easier access
    var dayViews: [DayColumnView]!
    
    // MARK: - Private state
    
    private var calendar: CalendarHelper {
        return CalendarHelper.shared
    }
    
    private var repository: DataRepository {
        return Storage.shared.repository
    }
    
    private var model: [DayColumnData] = []

    // Current stamps selected for the day
    var currentStamps = [Int64]()
    // Flag indicating whether we need to refresh table underneath when dismissing day view
    var dataChanged = false

    var currentDay = Date()
    
    private var favs = [Stamp]()

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = TodayPresenter(
            repository: repository,
            view: self)
        
        configureViews()
        prepareData()
        
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {
        dayViews = [day0, day1, day2, day3, day4, day5, day6]
        
        stampSelector.onStampTapped = { (stampId) in
            if self.currentStamps.contains(stampId) {
                self.currentStamps.removeAll { $0 == stampId }
            } else {
                self.currentStamps.append(stampId)
            }
            self.loadStampsData()
        }
    }
    
    private func prepareData() {
        model = CalendarDataBuilder(repository: repository, calendar: calendar).weekDataForToday()
        currentStamps = repository.stampsIdsForDay(currentDay)
    }
    
    private func loadDayData() {
        guard model.count == 7 else { return }
        for (data, view) in zip(model, dayViews) {
            view.loadData(data: data)
        }
    }

    private func loadStampsData() {
        let stamps = repository.allStamps()
        stampSelector.loadData(data: stamps.compactMap({
            guard let id = $0.id else { return nil }
            return DayStampData(
                stampId: id,
                label: $0.label,
                color: $0.color,
                isEnabled: currentStamps.contains(id) == false)
        }))
    }
    
    private func loadData() {
        loadDayData()
        loadStampsData()
    }
}
