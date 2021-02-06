//
//  StringExtensions.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

extension BidirectionalCollection where Element: StringProtocol {
    var sentence: String {
        guard let last = last else { return "" }
        return count <= 2 ? joined(separator: " and ") :
            dropLast().joined(separator: ", ") + ", and " + last
    }
}
