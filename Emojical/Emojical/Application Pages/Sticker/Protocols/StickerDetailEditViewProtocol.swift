//
//  StickerDetailEditViewProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

protocol StickerDetailEditViewProtocol: AnyObject {

    // MARK: - Callbacks
    
    /// User changed any value
    var onValueChanged: (() -> Void)? { get set }

    /// User tapped on list of stickers
    var onColorSelected: ((Int) -> Void)? { get set }

    /// User tapped on last color selection
    var onCustomColorTapped: (() -> Void)? { get set }

    // MARK: - Data
    
    /// Currently selected color
    var selectedColor: UIColor { get }

    /// Sticker name value
    var name: String? { get }
    
    /// Sticker emoji value
    var emoji: String? { get }
    
    // MARK: - Updates

    /// Configure view with data 
    func configure(for data: StickerEditData)

    /// Sets color palette (7 built-in colors)
    func setPaletteColors(_ colors: [UIColor])

    /// Sets custom color value
    func setCustomColor(_ color: UIColor)

    /// Set emoji field to first responder and bring the keyboard up
    func focusOnEmojiField()
    
    /// Update preview icon
    func updatePreview(label: String, color: UIColor)
}
