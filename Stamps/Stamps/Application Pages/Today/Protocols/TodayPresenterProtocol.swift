//
//  TodayPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol TodayPresenterProtocol: AnyObject {
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
    
    /// Navigate Today view to specific date
    func navigateTo(_ date: Date)
    
    /// Show week recap for the specific date (any daty in a week will do)
    func showWeekRecapFor(_ date: Date)
}
