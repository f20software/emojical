//
//  StickerMonthlyBoxView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickerMonthlyBoxView: AnyObject {

    // MARK: - Callbacks
    
    /// User tapped on the previous week button
    var onPrevButtonTapped: (() -> Void)? { get set }

    /// User tapped on the next week button
    var onNextButtonTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Load stats for the month
    func loadMonthData(header: String, data: [MonthBoxData])

    /// Show/hide next/prev button
    func showNextPrevButtons(showPrev: Bool, showNext: Bool)
}
