//
//  Theme.swift
//  FMClient
//
//  Created by Alexander Rogachev on 01.06.2020.
//  Copyright © 2020 Feed Me LLC. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Theme changing notifications
extension Notification.Name {
    /// Notification will be send by Theme default instance when text size is changed for the device
    static let fontChanged = Notification.Name("com.svidersky.emojical.notifications.SystemFontSizeChanged")
}

/// Theme aggregator
final class Theme {

    // Hiding init
    init(lightColors: Colors, darkColors: Colors) {
        self.lightColors = lightColors
        self.darkColors = darkColors
//        self.specs = Specs()
        self.fonts = Fonts()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFonts),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    /// Shared instance.
    private(set) static var shared: Theme = Theme.main()

    // MARK: - Theme values.

    /// Is Dark Mode enabled
    private var isDarkMode: Bool {
        UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }
    
    /// List of colors for the Light Mode
    private let lightColors: Colors
    
    /// List of colors for the Dark Mode
    private let darkColors: Colors
    
    /// Public list of color (will return proper set of colors based on light / dark mode)
    var colors: Colors {
        return isDarkMode ? darkColors : lightColors
    }

    /// List of theme Specs
//    let specs: Specs

    /// List of theme fonts.
    private(set) var fonts: Fonts

    // MARK: - Definitions

    struct Colors {
        /// Main application tint color
        let tint: UIColor
        
        
        let background: UIColor


        let secondaryBackround: UIColor

        ///
        let text: UIColor

        ///
        let secondaryText: UIColor
        
        ///
        let pallete: [UIColor]
    }

    // MARK: - Private

    @objc private func updateFonts() {
        self.fonts = Fonts()
        NotificationCenter.default.post(name: .fontChanged, object: nil, userInfo: nil)
    }
}
