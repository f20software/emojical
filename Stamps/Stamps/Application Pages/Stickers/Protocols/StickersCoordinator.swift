//
//  StickersCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickersCoordinator: AnyObject {

    /// Navigates to developer options page.
    func editGoal(_ goalId: Int64)

    /// Navigates to developer options page.
    func newGoal()

    /// Navigates to notification options page.
    func editSticker(_ stampId: Int64)

    /// Navigates to developer options page.
    func newSticker()
}
