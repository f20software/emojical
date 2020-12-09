//
//  StatsView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StatsView: AnyObject {

    // MARK: - Callbacks
    
    /// User tapped on the mode selector on the top of the screen
    var onModeChanged: ((StatsMode) -> Void)? { get set }

    /// User tapped on the previous week button
    var onPrevButtonTapped: (() -> Void)? { get set }

    /// User tapped on the next week button
    var onNextButtonTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Update page header
    func setHeader(to text: String)

    /// Update collection view layout to appropriate mode
    func updateLayout(to mode: StatsMode)

    /// Load stats for the week
    func loadWeekData(header: WeekHeaderData, data: [WeekLineData])
    
    /// Load stats for the month
    func loadMonthData(data: [MonthBoxData])

    /// Show/hide next week button
    func showNextWeekButton(_ show: Bool)
    
    /// Show/hide previous week button
    func showPrevWeekButton(_ show: Bool)
}
