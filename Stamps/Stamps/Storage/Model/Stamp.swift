//
//  Stamp.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct Stamp {
    var id: Int64?
    var name: String
    var label: String
    var color: UIColor
    var favorite: Bool = true
    var deleted: Bool = false
    var count: Int = 0
    var lastUsed: Date?

    /// Default new sticker
    static var new: Stamp {
        return Stamp(
            id: nil,
            name: "",
            label: "",
            color: Theme.shared.colors.palette.first!
        )
    }
}

extension Stamp: Equatable, Hashable {}
