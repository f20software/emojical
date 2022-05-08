//
//  GoalsView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

protocol GoalsView: AnyObject {

    /// Return UIViewController instance (so we can present alert stuff from Presenter class)
    var viewController: UIViewController? { get }
    
    /// User tapped on the goal
    var onGoalTapped: ((Int64) -> Void)? { get set }

    /// User tapped on the create new goal
    var onNewGoalTapped: (() -> Void)? { get set }

    /// User tapped on Add button
    var onAddButtonTapped: (() -> Void)? { get set }

    /// User tapped on Goals Examples button
    var onGoalsExamplesTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Update page title
    func updateTitle(_ text: String)

    /// Load stats for the month
    func loadData(goals: [GoalData])
}
