//
//  UIView+ThemeObserving.swift
//  Emojical
//
//  Created by Vladimit Svidersky on 02/06/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class ThemeObservingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        subscribeToThemeChanges()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        subscribeToThemeChanges()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    /// Subscribes to theme changing events from notification center.
    func subscribeToThemeChanges() {
        _ = NotificationCenter.default.addObserver(
            forName: .fontChanged, object: nil, queue: .main) { [weak self] _ in
            self?.updateFonts()
        }
    }

    /// Updates fonts used in view's labels. Should be overriden in derived classes.
    func updateFonts() { }

    /// Updates colors used in view. Should be overriden in derived classes.
    func updateColors() { }
}
