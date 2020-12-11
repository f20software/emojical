//
//  StickersCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickersCoordinator: AnyObject {

    /// Push to edit goal form
    func editGoal(_ goalId: Int64)

    /// Shows modal form to create new goal
    func newGoal()

    /// Push to edit sticker form
    func editSticker(_ stampId: Int64)

    /// Shows modal form to create new sticker
    func newSticker()
}
