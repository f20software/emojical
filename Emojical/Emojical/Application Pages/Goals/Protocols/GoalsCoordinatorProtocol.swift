//
//  GoalsCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalsCoordinatorProtocol: AnyObject {

    /// Push to edit goal form
    func editGoal(_ goal: Goal)

    /// Shows modal form to create new goal
    func newGoal()

    /// Shows modal form to select a goal from example library
    func newGoalFromExamples()
}
