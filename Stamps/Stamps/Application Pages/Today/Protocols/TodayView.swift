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

    /// User tapped on create new stamp in the bottom stamp selector
    var onNewStickerTapped: (() -> Void)? { get set }

    /// User tapped on the day header, day index 0...6 is passed
    var onDayHeaderTapped: ((Int) -> Void)? { get set }

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)? { get set }

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)? { get set }

    /// User tapped on the plus button
    var onPlusButtonTapped: (() -> Void)? { get set }

    /// User wants to dismiss Stamp Selector (by dragging it down)
    var onCloseStampSelector: (() -> Void)? { get set }

    /// User tapped on the award icon on the top
    var onAwardTapped: (() -> Void)? { get set }

    /// User wants to dismiss Awards Recap view (by dragging it down)
//    var onAwardsRecapDismiss: (() -> Void)? { get set }

    // MARK: - Updates

    /// Show/hide top awards strip
    func showAwards(_ show: Bool)
    
    /// Update page title
    func setTitle(to title: String)
    
    /// Show/hide next/prev button
    func showNextPrevButtons(showPrev: Bool, showNext: Bool)

    /// Loads header data
    func loadWeekHeader(data: [DayHeaderData])

    /// Loads stamps data into day columns
    func loadDays(data: [[StickerData]])
    
    /// Loads stamps into stamp selector
    func loadStampSelector(data: [StampSelectorElement])
    
    /// Loads awards data
    func loadAwards(data: [GoalAwardData])
    
    /// Show/hide stamp selector and plus button
    func showStampSelector(_ state: SelectorState)

    /// Show/hide awards recap view
//    func showAwardsRecap(_ show: Bool)
}
