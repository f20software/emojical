//
//  PresentationMode.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum PresentationMode {
    /// Modal presentation - editing new goal initially
    case modal
    /// Push presentation - viewing goal initially, can switch to edit mode
    case push
}
