//
//  Theme+Fonts.swift
//  Emojical
//
//  Created by Vladimit Svidersky on 02/06/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

extension Theme {

    /// Application fonts registry.
    class Fonts {

        /// List item title font (i.e. restaurant name)
        lazy var listTitle: UIFont = {
            font(ofSize: 20, weight: .semibold, style: .body)
        }()

        /// List item subtitle font (i.e. restaurant type)
        lazy var listBody: UIFont = {
            font(ofSize: 18, weight: .regular, style: .body)
        }()

        /// Caption for form fields (when editing Goal / Sticker)
        lazy var formFieldCaption: UIFont = {
            font(ofSize: 18, weight: .regular, style: .body)
        }()

        /// Caption for form fields (when editing Goal / Sticker)
        lazy var formFieldBoldCaption: UIFont = {
            font(ofSize: 18, weight: .bold, style: .body)
        }()

        /// Footer for the form (when editing Goal / Sticker)
        lazy var footer: UIFont = {
            font(ofSize: 14, weight: .regular, style: .body)
        }()
        
        /// Bold buttons text font
        lazy var boldButtons: UIFont = {
            font(ofSize: 20, weight: .semibold, style: .body)
        }()

        /// Buttons text font
        lazy var buttons: UIFont = {
            font(ofSize: 18, weight: .regular, style: .body)
        }()

        /// Large stats text font
        lazy var largeStats: UIFont = {
            font(ofSize: 32, weight: .bold, style: .body)
        }()

        /// Empty cells ("no goals...") description text
        lazy var cellDescription: UIFont = {
            font(ofSize: 16, weight: .semibold, style: .body)
        }()

        /// Section header title
        lazy var sectionHeaderTitle: UIFont = {
            font(ofSize: 15, weight: .bold, style: .body)
        }()

        /// Section header title for stats screen
        lazy var statsNumbers: UIFont = {
            font(ofSize: 14, weight: .bold, style: .body)
        }()

        /// Returns a base font scaled according to current system font size.
        ///
        /// - parameters:
        ///    - size: Base font size
        ///    - weight: Base font weight
        ///    - style: Parent font style
        ///
        /// - returns: Font with specified weight, scaled according to system
        ///            font size based on given system font style.
        private func font(ofSize size: CGFloat, weight: UIFont.Weight, style: UIFont.TextStyle) -> UIFont {
            let font = UIFont.systemFont(ofSize: size, weight: weight)
            return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
        }
    }
}
