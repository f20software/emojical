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
    
    @IBOutlet weak var selectedDayIndicator: UIView!
    @IBOutlet weak var selectedDayIndicatorLeading: NSLayoutConstraint!

    @IBOutlet var prevWeek: UIBarButtonItem!
    @IBOutlet var nextWeek: UIBarButtonItem!

    @IBOutlet weak var day0: DayColumnView!
    @IBOutlet weak var day1: DayColumnView!
    @IBOutlet weak var day2: DayColumnView!
    @IBOutlet weak var day3: DayColumnView!
    @IBOutlet weak var day4: DayColumnView!
    @IBOutlet weak var day5: DayColumnView!
    @IBOutlet weak var day6: DayColumnView!
    
    @IBOutlet weak var lockIcon: UIImageView!
    @IBOutlet weak var stampSelector: StampSelectorView!

    // MARK: - DI

    var presenter: TodayPresenterProtocol!

    // Reference arrays for easier access
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = TodayPresenter(
            repository: Storage.shared.repository,
            stampsListener: Storage.shared.stampsListener(),
            awards: AwardManager.shared,
            calendar: CalendarHelper.shared,
            view: self)
        
        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - TodayView
    
    /// Is called when user tapped on the stamp in the bottom stamp selector
    var onStampInSelectorTapped: ((Int64) -> Void)?

    /// Is called when user tapped on the day header, day index 0...6 is passed
    var onDayHeaderTapped: ((Int) -> Void)?

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)?

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)? 

    /// Update page title
    func setTitle(to title: String) {
        navigationItem.title = title
    }

    /// Move selected day indicator
    func setSelectedDay(to index: Int) {
        DispatchQueue.main.async {
            let size = self.day0.bounds.width
            self.selectedDayIndicatorLeading.constant = CGFloat(index) * size + size / 2
        }
    }

    /// Loads stamps and header data into day columns
    func loadDaysData(data: [DayColumnData]) {
        guard data.count == 7 else { return }
        let dayViews: [DayColumnView] = [day0, day1, day2, day3, day4, day5, day6]
        
        // Mapping 7 data objects to 7 day views
        for (day, view) in zip(data, dayViews) {
            view.loadData(data: day)
        }
    }

    /// Loads stamps into stamp selector
    func loadStampSelectorData(data: [DayStampData]) {
        stampSelector.loadData(data: data)
    }
    
    /// Show/hide next week button
    func showNextWeekButton(_ show: Bool) {
        navigationItem.rightBarButtonItem = show ? nextWeek : nil
    }
    
    /// Show/hide previous week button
    func showPrevWeekButton(_ show: Bool) {
        navigationItem.leftBarButtonItem = show ? prevWeek : nil
    }

    /// Show/hide lock icon
    func showLock(_ show: Bool) {
        lockIcon.isHidden = !show
    }

    // MARK: - Actions
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        onPrevWeekTapped?()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        onNextWeekTapped?()
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {
        
        selectedDayIndicator.layer.cornerRadius = selectedDayIndicator.bounds.height / 2
        selectedDayIndicator.backgroundColor = UIColor.systemGray3
        selectedDayIndicator.clipsToBounds = true
        
        stampSelector.onStampTapped = { (stampId) in
            self.onStampInSelectorTapped?(stampId)
        }
        day0.onDayTapped = { () in
            self.onDayHeaderTapped?(0)
        }
        day1.onDayTapped = { () in
            self.onDayHeaderTapped?(1)
        }
        day2.onDayTapped = { () in
            self.onDayHeaderTapped?(2)
        }
        day3.onDayTapped = { () in
            self.onDayHeaderTapped?(3)
        }
        day4.onDayTapped = { () in
            self.onDayHeaderTapped?(4)
        }
        day5.onDayTapped = { () in
            self.onDayHeaderTapped?(5)
        }
        day6.onDayTapped = { () in
            self.onDayHeaderTapped?(6)
        }
    }
}
