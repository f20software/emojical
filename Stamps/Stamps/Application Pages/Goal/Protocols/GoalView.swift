//
//  GoalView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalView: AnyObject {

    // MARK: - Callbacks
    
    /// User tapped on the edit button
    var onEditTapped: (() -> Void)? { get set }

    /// User tapped on the Cancel button
    var onCancelTapped: (() -> Void)? { get set }

    /// User tapped on the Done button
    var onDoneTapped: (() -> Void)? { get set }

    /// User tapped on the delete button
    var onDeleteTapped: (() -> Void)? { get set }

    // MARK: - Updates

    /// Dismisses view if it was presented modally
    func dismiss()

    /// Set / reset editing mode
    func setEditing(_ editing: Bool, animated: Bool)

    /// Loads Goal data
    func loadGoal(data: [GoalDetailsElement])
}
