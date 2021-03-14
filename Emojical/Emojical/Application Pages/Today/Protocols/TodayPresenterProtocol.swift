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
    
    /// Called when view about to disappear from the screen
    func onViewWillDisappear()

    /// Navigate Today view to specific date
    func navigateTo(_ date: Date)
    
    /// Show week recap for the specific date (any daty in a week will do)
    func showWeekRecapFor(_ date: Date)
    
    /// Process single Coach message (could be onboarding message or cheers for reaching the goal or anything else)
    func showCoachMessage(_ message: CoachMessage, completion: (() -> Void)?)
}
