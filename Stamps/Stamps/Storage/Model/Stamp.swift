//
//  Stamp.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct Stamp: Equatable, Hashable {
    var id: Int64?
    var name: String
    var label: String
    var color: UIColor
    var favorite: Bool = true
    var deleted: Bool = false
    var count: Int = 0
    var lastUsed: Date?
    
    var statsDescription: String {
        if count <= 0 {
            return "Sticker hasn't been used yet."
        }
        
        var result = "Sticker has been used "
        if count > 1 {
            result += "\(count) times"
        }
        else {
            result += "1 time"
        }
        
        if let lastUsed = lastUsed {
            let df = DateFormatter()
            df.dateStyle = .medium
            result += ", last time - \(df.string(from: lastUsed))."
        }
        else {
            result += "."
        }
        
        return result
    }
    
    static var new: Stamp {
        return Stamp(id: nil, name: "Gold Star", label: "⭐️", color: UIColor(hex: UIColor.defaultStickerColor))
    }
}
