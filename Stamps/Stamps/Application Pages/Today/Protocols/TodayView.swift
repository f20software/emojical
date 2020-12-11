//
//  TodayView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol TodayView: AnyObject {

    // MARK: - Callbacks
    
    /// User tapped on the stamp in the bottom stamp selector
    var onStampInSelectorTapped: ((Int64) -> Void)? { get set }

    /// User tapped on the day header, day index 0...6 is passed
    var onDayHeaderTapped: ((Int) -> Void)? { get set }

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)? { get set }

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)? { get set }

    /// User tapped on the plus button
    var onPlusButtonTapped: (() -> Void)? { get set }

    /// User tapped to close selector button
    var onCloseStampSelectorTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Show/hide top awards strip
    func showAwards(_ show: Bool)
    
    /// Update page title
    func setTitle(to title: String)
    
    /// Show/hide next/prev button
    func showNextPrevButtons(showPrev: Bool, showNext: Bool)

    /// Move selected day indicator
    func setSelectedDay(to index: Int)
    
    /// Loads stamps and header data into day columns
    func loadDaysData(data: [DayColumnData])
    
    /// Loads stamps into stamp selector
    func loadStampSelectorData(data: [DayStampData])
    
    /// Loads awards data
    func loadAwardsData(data: [TodayAwardData])
    
    /// Show/hide stamp selector and plus button
    func showStampSelector(_ state: SelectorState)
}
