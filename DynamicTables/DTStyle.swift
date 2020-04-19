//
//  DTStyle.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

public extension UIColor {

    class func rgbColor(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red:red/255.0, green:green/255.0, blue:blue/255.0, alpha:1.0)
    }
}

enum ColorKey {
    case backgroundColor
    case redColor
    case tintColor
    case textColor
    case alternateTextColor
}

let defaultDarkTheme: [ColorKey: UIColor] = [
    .backgroundColor: UIColor.secondarySystemGroupedBackground,
    .textColor: UIColor.label,
    .alternateTextColor: UIColor.secondaryLabel,
    .tintColor: UIColor.rgbColor(0, green: 96, blue: 167), // Main blue color
    .redColor: UIColor.systemRed,
]


class DTStyle: NSObject {

    static func sequoiaBlueColor() -> UIColor {
        return UIColor.rgbColor(0, green: 97, blue: 170)
    }
    
    static func themeColor(_ key: ColorKey) -> UIColor {
        guard defaultDarkTheme[key] != nil else {
        
            return UIColor.black
        }
        
        return defaultDarkTheme[key]!
    }
}
