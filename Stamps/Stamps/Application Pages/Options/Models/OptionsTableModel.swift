//
//  OptionsTableModel.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct Section {
    let header: String?
    let footer: String?
    var cells: [Cell]
}

enum Cell {
    case text(String?, String? = nil)
    case `switch`(String, Bool, ((Bool) -> Void)?)
    case navigate(String, (() -> Void)?)
    case button(String, (() -> Void)?)
}

extension Cell: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .text(let name, let value):
            return "\(name ?? "")\(value ?? "")".hash(into: &hasher)
        case .`switch`(let value, _, _):
            return value.hash(into: &hasher)
        case .navigate(let value, _):
            return value.hash(into: &hasher)
        case .button(let value, _):
            return value.hash(into: &hasher)
        }
    }

    static func ==(lhs: Cell, rhs: Cell) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhsValue1, let lhsValue2), .text(let rhsValue1, let rhsValue2)):
            return (lhsValue1 == rhsValue1) && (lhsValue2 == rhsValue2)
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

extension Section: Equatable, Hashable {}
