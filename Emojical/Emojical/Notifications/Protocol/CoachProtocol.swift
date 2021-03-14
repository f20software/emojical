//
//  CoachProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol CoachProtocol {

    /// Coach listener instance
    func coachListener() -> CoachListener

    /// Testing various messages sent by ValetManager
    func mockMessage(_ message: CoachMessage)
}
