//
//  Theme+Fonts.swift
//  FMClient
//
//  Created by Alexander Rogachev on 23.06.2020.
//  Copyright © 2020 Feed Me LLC. All rights reserved.
//

import Foundation
import UIKit

extension Theme {

    /// Application fonts registry.
    class Fonts {

        /// List item title font (i.e. restaurant name)
        lazy var listTitle: UIFont = {
            font(ofSize: 20, weight: .bold, style: .body)
        }()

        /// List item subtitle font (i.e. restaurant type)
        lazy var listBody: UIFont = {
            font(ofSize: 18, weight: .regular, style: .body)
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
