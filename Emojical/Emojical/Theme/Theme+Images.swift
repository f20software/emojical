//
//  Theme+Images.swift
//  Emojical
//
//  Created by Vladimit Svidersky on 5/7/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

extension Theme {

    /// Application common specs
    struct Images {
    
        /// Plus button used to create new stuff
        let plusButton = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
        
        /// Crown image to be shown on the empty Goals screen
        let crown = UIImage(
            systemName: "crown",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
    }
}
