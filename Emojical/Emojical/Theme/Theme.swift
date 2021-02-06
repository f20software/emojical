//
//  Theme.swift
//  Emojical
//
//  Created by Vladimit Svidersky on 02/06/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
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
    init() {
        self.specs = Specs()
        self.fonts = Fonts()
        self.colors = Colors()

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
    private(set) static var main: Theme = Theme()

    // MARK: - Theme values.

    /// List of theme Specs
    private(set) var specs: Specs

    /// List of theme fonts.
    private(set) var fonts: Fonts

    /// List of theme colors.
    private(set) var colors: Colors

    // MARK: - Private

    @objc private func updateFonts() {
        self.fonts = Fonts()
        NotificationCenter.default.post(name: .fontChanged, object: nil, userInfo: nil)
    }
}
