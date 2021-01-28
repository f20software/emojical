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

    /// User tapped on list of stickers to select
    var onSelectStickersTapped: (() -> Void)? { get set }

    /// Uer has changed any data 
    var onGoalChanged: (() -> Void)? { get set }

    // MARK: - Updates

    /// Dismisses Goal view 
    func dismiss(from mode: PresentationMode)

    /// Set / reset editing mode
    func setEditing(_ editing: Bool, animated: Bool)

    /// Set form title
    func updateTitle(_ text: String)

    /// Enable / disable Done button data
    func enableDoneButton(_ enabled: Bool)

    /// Loads Goal data
    func loadData(_ data: [GoalDetailsElement])

    /// Update Goal data from the UI
    func update(to: inout Goal)
}
