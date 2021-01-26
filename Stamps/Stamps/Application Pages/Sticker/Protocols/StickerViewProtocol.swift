//
//  StickerViewProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickerViewProtocol: AnyObject {

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
    var onStickerChanged: (() -> Void)? { get set }

    // MARK: - Updates

    /// Dismisses Goal view 
    func dismiss(from mode: PresentationMode)

    /// Set / reset editing mode
    func setEditing(_ editing: Bool, animated: Bool)
    
    /// When creating new sticker we want to bring emoji keyboard immediately
    func focusOnEmoji()

    /// Set form title
    func updateTitle(_ text: String)

    /// Set form title
    func updateIcon(_ sticker: Stamp)

    /// Enable / disable Done button data
    func enableDoneButton(_ enabled: Bool)

    /// Loads Sticker data
    func loadStickerData(_ data: [StickerDetailsElement])

    /// Update Sticker data from the UI
    func update(to: inout Stamp)
}
