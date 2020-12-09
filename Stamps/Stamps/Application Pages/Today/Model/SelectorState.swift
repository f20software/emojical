//
//  SelectorState.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/08/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum SelectorState: Hashable {
    /// Nothing is visible - user cannot add stamps
    case hidden
    
    /// Small button is shown to expand the big stamp selector
    case miniButton
    
    /// Full stamp selector is shown
    case fullSelector
}
