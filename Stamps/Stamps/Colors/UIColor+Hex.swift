//
//  UIColor+Hex.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension UIColor {
    
    public convenience init(hex: String) {
        let r, g, b: CGFloat

        guard hex.count == 6 else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
            return
        }
            
        let scanner = Scanner(string: "0x\(hex)")
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255
            // a = CGFloat(hexNumber & 0x000000ff) / 255

            self.init(red: r, green: g, blue: b, alpha: 1.0)
        }
        else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        }
    }
}
