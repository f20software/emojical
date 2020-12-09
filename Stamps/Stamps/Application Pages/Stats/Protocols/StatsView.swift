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
    var onModeChanged: ((Int) -> Void)? { get set }

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)? { get set }

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Show/hide next week button
    func showNextWeekButton(_ show: Bool)
    
    /// Show/hide previous week button
    func showPrevWeekButton(_ show: Bool)
}
