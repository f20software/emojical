//
//  Theme+Main.swift
//  FMClient
//
//  Created by Alexander Rogachev on 01.06.2020.
//  Copyright © 2020 Feed Me LLC. All rights reserved.
//

import Foundation
import UIKit

extension Theme {

    /// Returns refault theme.
    static func main() -> Theme {

        let light = Colors(
            /// Main application tint color
            tint: UIColor(r: 13, g: 15, b: 45),

            ///
            caption: UIColor.gray
        )

        let dark = Colors(
            /// Main application tint color
            tint: UIColor(r: 13, g: 15, b: 45),
            
            ///
            caption: UIColor.lightGray
        )

        return Theme(lightColors: light, darkColors: dark)
    }
}
