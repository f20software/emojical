//
//  UIColorExtensions.swift
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
    
    public convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }

    public var hex: String {
        if let componets = cgColor.components {
            if componets.count > 2 {
                return String(
                    format: "%02lX%02lX%02lX",
                    lroundf(Float(componets[0]) * 255),
                    lroundf(Float(componets[1]) * 255),
                    lroundf(Float(componets[2]) * 255))
            } else {
                return "000000"
            }
        } else {
            return "000000"
        }
    }
}

extension UIColor {

func lighter(by percentage: CGFloat = 10.0) -> UIColor {
    return self.adjust(by: abs(percentage))
}

func darker(by percentage: CGFloat = 10.0) -> UIColor {
    return self.adjust(by: -abs(percentage))
}

func adjust(by percentage: CGFloat) -> UIColor {
    var alpha, hue, saturation, brightness, red, green, blue, white : CGFloat
    (alpha, hue, saturation, brightness, red, green, blue, white) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    let multiplier = percentage / 100.0

    if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        let newBrightness: CGFloat = max(min(brightness + multiplier*brightness, 1.0), 0.0)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha * 0.1)
    }
    else if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
        let newRed: CGFloat = min(max(red + multiplier*red, 0.0), 1.0)
        let newGreen: CGFloat = min(max(green + multiplier*green, 0.0), 1.0)
        let newBlue: CGFloat = min(max(blue + multiplier*blue, 0.0), 1.0)
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha * 0.1)
    }
    else if self.getWhite(&white, alpha: &alpha) {
        let newWhite: CGFloat = (white + multiplier*white)
        return UIColor(white: newWhite, alpha: alpha)
    }

    return self
    }
}
