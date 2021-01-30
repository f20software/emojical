//
//  GoalData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct OptionsSection {
    let header: String?
    let footer: String?
    let cells: [OptionsCell]
}

enum OptionsCell {
    case text(String)
    case `switch`(String, Bool, ((Bool) -> Void)?)
    case navigate(String, (() -> Void)?)
    case button(String, (() -> Void)?)
}

extension OptionsCell: Equatable, Hashable {
    
    var hashValue: Int {
        switch self {
        case .text(let value):
            return value.hashValue
        case .`switch`(let value, _, _):
            return value.hashValue
        case .navigate(let value, _):
            return value.hashValue
        case .button(let value, _):
            return value.hashValue
        }
    }

    static func ==(lhs: OptionsCell, rhs: OptionsCell) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhsValue), .text(let rhsValue)):
            return lhsValue == rhsValue
        case (.`switch`(let lhsValue, _, _), .`switch`(let rhsValue, _, _)):
            return lhsValue == rhsValue
        case (.navigate(let lhsValue, _), .navigate(let rhsValue, _)):
            return lhsValue == rhsValue
        case (.button(let lhsValue, _), .button(let rhsValue, _)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension OptionsSection: Equatable, Hashable {}
