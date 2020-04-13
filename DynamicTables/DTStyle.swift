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
    case tableSeparatorColor
    case kioskBackgroundColor
    case redOfflineColor
    case tintColor
    case textColor
    case contranstTextColor
    case alternateTextColor
    case fieldBackgroundColor
    case selectedItemColor

    case pastEventColor
    case runningEventColor
    case lowInventoryEventColor
    case veryLowInventoryEventColor

    case emptyTableColor
    case paidTableColor
    case resumedTableColor
    case suspendedTableColor

    case disabledButtonColor
    case nextButtonColor
    case signInButtonColor
    case runReportButtonColor

    // Jobs colors
    case jobSuccessfullColor
    case jobFailedColor
    
    // List of items colors
    case itemBackgroundColor
    case itemOutOfStockBackgroundColor
    
    // Hangry locations and orders colors
    case locationOnlineBackgroundColor
    case locationBusyBackgroundColor
    case locationOfflineBackgroundColor
    case locationTestBackgroundColor
    
    case orderLateColor
    case orderNormalColor
}

let defaultDarkTheme: [ColorKey: UIColor] = [
    
    .tintColor: UIColor.rgbColor(0, green: 96, blue: 167), // Main blue color
    .backgroundColor: UIColor.rgbColor(19, green: 39, blue: 51),

    .tableSeparatorColor: UIColor.darkGray,
    .selectedItemColor: UIColor.darkGray,
    
    .kioskBackgroundColor: UIColor.rgbColor(0, green: 96, blue: 167), // Main blue color
    .redOfflineColor: UIColor.rgbColor(246, green: 50, blue: 62),
    
    .textColor: UIColor.white,
    .alternateTextColor: UIColor.lightGray,
    .contranstTextColor: UIColor.rgbColor(19, green: 39, blue: 51), // Same as background
    
    .pastEventColor: UIColor.rgbColor(123, green: 146, blue: 163), // Grey color from iValidate
    .runningEventColor: UIColor.rgbColor(0, green: 187, blue: 179), // Green color from iValidate
    .veryLowInventoryEventColor: UIColor.rgbColor(246, green: 50, blue: 62), // Red color from iValidate
    .lowInventoryEventColor: UIColor.rgbColor(255, green: 97, blue: 0), // Organge color from iValidate
    
    .fieldBackgroundColor: UIColor.rgbColor(38, green: 52, blue: 61),
    
    .emptyTableColor: UIColor.rgbColor(123, green: 146, blue: 163), // Grey color from iValidate
    .paidTableColor: UIColor.rgbColor(0, green: 187, blue: 179), // Green color from iValidate
    .resumedTableColor: UIColor.rgbColor(0, green: 187, blue: 179), // Green color from iValidate
    .suspendedTableColor: UIColor.rgbColor(255, green: 97, blue: 0), // Organge color from iValidate
    
    .disabledButtonColor: UIColor.rgbColor(38, green: 52, blue: 61), // Same as field background color
    .nextButtonColor: UIColor.rgbColor(0, green: 187, blue: 179), // Green color from iValidate
    .runReportButtonColor: UIColor.rgbColor(0, green: 187, blue: 179), // Green color from iValidate
    .signInButtonColor: UIColor.rgbColor(0, green: 96, blue: 167), // Main blue color
    
    .jobFailedColor: UIColor.rgbColor(243, green: 63, blue: 58), // Red failed color from iValidate
    .jobSuccessfullColor: UIColor.rgbColor(0, green: 187, blue: 179), // Green success color from iValidate
    
    .itemBackgroundColor: UIColor.rgbColor(123, green: 146, blue: 163), // Grey color from iValidate
    .itemOutOfStockBackgroundColor: UIColor.rgbColor(246, green: 50, blue: 62), // Red color from iValidate
    
    .locationOnlineBackgroundColor: UIColor.rgbColor(0, green: 96, blue: 167), // Main blue color
    .locationBusyBackgroundColor: UIColor.rgbColor(255, green: 97, blue: 0), // Organge color from iValidate
    .locationOfflineBackgroundColor: UIColor.rgbColor(246, green: 50, blue: 62), // Red color from iValidate
    .locationTestBackgroundColor: UIColor.rgbColor(123, green: 146, blue: 163), // Grey color from iValidate

    .orderLateColor: UIColor.rgbColor(246, green: 50, blue: 62), // Red color from iValidate
    .orderNormalColor: UIColor.rgbColor(123, green: 146, blue: 163), // Grey color from iValidate
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
    
    static func createSeparatorView(_ view: UIView, color: UIColor) {
        
        // view.backgroundColor = UIColor.clearColor()
        // return
         
        let path = UIBezierPath()
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width, y: height / 2))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = height
        shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
        shapeLayer.lineDashPattern = [NSNumber(value: Float(height+1)), NSNumber(value: Float(height))]
        shapeLayer.lineDashPhase = 1
        shapeLayer.path = path.cgPath
        
        view.backgroundColor = UIColor.clear
        view.layer.addSublayer(shapeLayer)
        view.clipsToBounds = true
    }
    
    static func setNavigationBarShadow(_ view: UIView?) {

        guard let view = view else { return }
        
        let shadowSize = 2 / UIScreen.main.scale
        view.layer.shadowOffset = CGSize(width: 0, height: shadowSize)
        view.layer.shadowRadius = shadowSize
        view.layer.shadowOpacity = 0.9
        view.layer.shadowColor = UIColor.black.cgColor
        view.clipsToBounds = false
    }

    static func setTabBarShadow(_ view: UIView?) {
        
        guard let view = view else { return }
        
        let shadowSize = 6 / UIScreen.main.scale
        view.layer.shadowOffset = CGSize(width: 0, height: -shadowSize)
        view.layer.shadowRadius = shadowSize
        view.layer.shadowOpacity = 0.9
        view.layer.shadowColor = UIColor.black.cgColor
        view.clipsToBounds = false
    }
    
    static func setTableCellStyle(_ cell: UITableViewCell?) {

        guard let cell = cell else { return }
        
        cell.backgroundColor = themeColor(.backgroundColor)
        cell.contentView.backgroundColor = themeColor(.backgroundColor)
        cell.textLabel?.textColor = themeColor(.alternateTextColor)
        cell.textLabel?.backgroundColor = themeColor(.backgroundColor)
        cell.detailTextLabel?.textColor = themeColor(.textColor)
        cell.detailTextLabel?.backgroundColor = themeColor(.backgroundColor)
    }
    
    static func updateAppearanceProxy() {
        
        // Table view
        UITableView.appearance().backgroundColor = DTStyle.themeColor(.backgroundColor)
        
        // Tabbar
        UITabBar.appearance().tintColor = DTStyle.themeColor(.tintColor)
        UITabBar.appearance().barStyle = .default
        
        // Navigation
        UINavigationBar.appearance().barTintColor = themeColor(.backgroundColor)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: themeColor(.textColor)
        ]
        UINavigationBar.appearance().tintColor = themeColor(.alternateTextColor)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: themeColor(.textColor),
            NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size:18.0)!
        ]
        UIButton.appearance().tintColor = DTStyle.themeColor(.alternateTextColor)
        UISwitch.appearance().onTintColor = DTStyle.sequoiaBlueColor()
    }
}
