//
//  Sticker.swift
//  Emojical
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct Sticker {
    /// Unique sticket Id - assigned automatically
    var id: Int64?
    
    /// Sticker name
    var name: String
    
    /// Emoji label
    var label: String
    
    /// Sticker background color
    var color: UIColor
    
    /// Not used
    var favorite: Bool = true
    
    /// `true` when sticker is deleted
    var deleted: Bool = false
    
    /// How many times sticker has been used
    var count: Int = 0
    
    /// Last time sticker was used
    var lastUsed: Date?

    /// Default new sticker
    static var new: Sticker {
        return Sticker(
            id: nil,
            name: "",
            label: "",
            color: Theme.main.colors.palette.first!
        )
    }
}

extension Sticker: Equatable, Hashable {}
