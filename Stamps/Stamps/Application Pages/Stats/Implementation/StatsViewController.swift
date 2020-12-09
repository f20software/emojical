//
//  TodayViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

class StatsViewController: UIViewController, StatsView {
    
    // MARK: - Outlets
    
    @IBOutlet var prevWeek: UIBarButtonItem!
    @IBOutlet var nextWeek: UIBarButtonItem!

    // MARK: - DI

    var presenter: StatsPresenterProtocol!

    // Reference arrays for easier access
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = StatsPresenter(
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
    
    /// User tapped on the mode selector on the top of the screen
    var onModeChanged: ((Int) -> Void)?

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)?

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)? 

    /// Update page title
    func setTitle(to title: String) {
        navigationItem.title = title
    }

    /// Show/hide next week button
    func showNextWeekButton(_ show: Bool) {
        navigationItem.rightBarButtonItem = show ? nextWeek : nil
    }
    
    /// Show/hide previous week button
    func showPrevWeekButton(_ show: Bool) {
        navigationItem.leftBarButtonItem = show ? prevWeek : nil
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
        
        prevWeek.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        nextWeek.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
}
