//
//  TodayCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/11/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol TodayCoordinatorProtocol: AnyObject {

    /// Shows modal form to create new sticker
    func newSticker()

    /// Navigates to goals / awards recap window
    func showAwardsRecap(data: [AwardRecapData])

    /// Shows congratulation window
    func showCongratsWindow(data: Award)

    /// Navigates to specific goal
    func showGoal(_ goal: Goal)

    /// Shows onboarding window
    func showOnboardingWindow(gap: Float)
}
