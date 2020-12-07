//
//  TodayView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/6/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol TodayView: AnyObject {

    // MARK: - Callbacks
    
    /// Is called when user tapped on the stamp in the bottom stamp selector
    var onStampInSelectorTapped: ((Int64) -> Void)? { get set }

    /// Is called when user tapped on the day header, day index 0...6 is passed
    var onDayHeaderTapped: ((Int) -> Void)? { get set }

    // MARK: - Updates

    /// Loads stamps and header data into day columns
    func loadDaysData(data: [DayColumnData])
    
    /// Loads stamps into stamp selector
    func loadStampSelectorData(data: [DayStampData])
}
