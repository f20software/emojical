//
//  Language+String.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Convinience extension to an array of string to combine words using English , and 
extension BidirectionalCollection where Element: StringProtocol {
    var sentence: String {
        guard let last = last else { return "" }
        return count <= 2 ? joined(separator: " and ") :
            dropLast().joined(separator: ", ") + ", and " + last
    }
}


/// Conviniece extension to String to capitalize first letter
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

