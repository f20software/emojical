//
//  Palette.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 2/1/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension UIColor {

    static let positiveGoalReached = UIColor(hex: UIColor.colorByName("Green"))
    static let negativeGoalReached = UIColor(hex: UIColor.colorByName("Red"))
    static let positiveGoalNotReached = UIColor(hex: UIColor.colorByName("Mint"))
    static let negativeGoalNotReached = UIColor(hex: UIColor.colorByName("Mint"))

    class func stampsPalette() -> [String: String] {
        return [
            "Gold": "B8B09b",
            "Grey": "7B92A3",
            "Sky Blue": "6AB1D8",
            "Blue": "0060A7",
            "Green": "00bd56",
            "Mint": "57D3A3",
            "Orange": "FF6A00",
            "Purple": "BC83C9",
            "Red": "F6323E",
            "Peach": "ED8C6B",
            "Yellow": "F9BE00"
        ]
    }
    
    class func nameByColor(_ color: String) -> String {
        return stampsPalette().first{ $0.value == color }?.key ?? "Unknown Color"
    }
    
    class func colorByName(_ name: String) -> String {
        return stampsPalette()[name] ?? "000000"
    }
}
