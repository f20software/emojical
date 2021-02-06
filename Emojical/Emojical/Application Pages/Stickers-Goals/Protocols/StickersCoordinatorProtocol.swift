//
//  StickersCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickersCoordinatorProtocol: AnyObject {

    /// Push to edit goal form
    func editGoal(_ goal: Goal)

    /// Shows modal form to create new goal
    func newGoal()

    /// Push to edit sticker form
    func editSticker(_ sticker: Stamp)

    /// Shows modal form to create new sticker
    func newSticker()

    /// Shows modal form to select a goal from example library
    func newGoalFromExamples()
}
