//
//  GoalsLibraryView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/6/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalsLibraryView: AnyObject {

    /// User tapped on the goal
    var onGoalTapped: ((Int64) -> Void)? { get set }

    /// User tapped on the Cancel button
    var onCancelTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Update page title
    func updateTitle(_ text: String)

    /// Load stats for the month
    func loadData(sections: [String], goals: [GoalExampleData])

    /// Dismisses Goals Library view
    func dismiss()
}
