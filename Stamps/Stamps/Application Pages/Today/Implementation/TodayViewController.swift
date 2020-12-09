//
//  TodayViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

class TodayViewController: UIViewController, TodayView {

    // MARK: - Outlets
    
    @IBOutlet weak var awards: WeeklyAwardsView!

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
    
    @IBOutlet weak var stampSelector: StampSelectorView!
    @IBOutlet weak var stampSelectorCloseButton: UIButton!
    @IBOutlet weak var stampSelectorBottomContstraint: NSLayoutConstraint!

    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var plusButtonBottomContstraint: NSLayoutConstraint!


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
            awardsListener: Storage.shared.awardsListener(),
            awardManager: AwardManager.shared,
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

    /// User tapped on the plus button
    var onPlusButtonTapped: (() -> Void)?

    /// User tapped to close selector button
    var onCloseStampSelectorTapped: (() -> Void)?

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

    /// Loads awards data
    func loadAwardsData(data: [TodayAwardData]) {
        awards.loadData(data: data)
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

    /// Show/hide stamp selector and plus button
    func showStampSelector(_ state: SelectorState) {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
            options: [.curveEaseInOut], animations:
        {
            self.stampSelectorBottomContstraint.constant = (state == .fullSelector) ? 16 : -200
            self.plusButtonBottomContstraint.constant = (state == .miniButton) ? 16 : -100
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - Actions
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        onPrevWeekTapped?()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        onNextWeekTapped?()
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        onPlusButtonTapped?()
    }

    @IBAction func closeSelectorTapped(_ sender: Any) {
        onCloseStampSelectorTapped?()
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        
        prevWeek.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        nextWeek.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        stampSelectorCloseButton.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!, for: .normal)

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
        
        plusButton.layer.cornerRadius = Specs.miniButtonCornerRadius
        plusButton.clipsToBounds = true
        plusButton.backgroundColor = UIColor.systemGray6
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Stamp selector mini button corner radius
    static let miniButtonCornerRadius: CGFloat = 8.0
}
