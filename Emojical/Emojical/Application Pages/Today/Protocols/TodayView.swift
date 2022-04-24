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
    
    /// User tapped on the sticker in the bottom sticker selector
    var onStickerInSelectorTapped: ((Int64) -> Void)? { get set }

    /// User tapped on create new sticker in the bottom sticker selector
    var onNewStickerTapped: (() -> Void)? { get set }

    /// User tapped on the day header, day index 0...6 is passed
    var onDayHeaderTapped: ((Int) -> Void)? { get set }

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)? { get set }

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)? { get set }

    /// User tapped on the plus button
    var onPlusButtonTapped: (() -> Void)? { get set }

    /// User wants to dismiss Sticker Selector (by dragging it down)
    var onCloseStickerSelector: (() -> Void)? { get set }

    /// User tapped on the award icon on the top
    var onAwardTapped: ((Int) -> Void)? { get set }

    /// User tapped on the recap button
    var onRecapTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Show/hide top awards strip
    func showAwards(_ show: Bool)
    
    /// Show/hide recap bubble
    func loadRecapBubbleData(_ data: RecapBubbleData?, show: Bool)

    /// Show/hide empty week bubble
    func loadEmptyWeekBubbleData(_ data: EmptyWeekBubbleData?)

    /// Update page title
    func setTitle(to title: String)
    
    /// Show/hide next/prev button
    func showNextPrevButtons(showPrev: Bool, showNext: Bool)

    /// Loads header data
    func loadWeekHeader(data: [DayHeaderData])

    /// Loads stamps data into day columns
    func loadDays(data: [[StickerData]])
    
    /// Loads StickerSelector view model data
    func loadStickerSelector(data: StickerSelectorData)
    
    /// Loads awards data
    func loadAwards(data: [GoalOrAwardIconData])
    
    /// Show/hide sticker selector and plus button
    func showStickerSelector(_ state: SelectorState)
    
    // MARK: - Layout
    
    /// Distance from the bottom of the screen to the top edge of Sticker Selector
    var stickerSelectorSize: Float { get }
}
