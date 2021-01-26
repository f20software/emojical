//
//  StickerCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickerCoordinatorProtocol: AnyObject {

    /// Shows modal form to create new goal
    func newGoal(with stickerId: Int64)
}
