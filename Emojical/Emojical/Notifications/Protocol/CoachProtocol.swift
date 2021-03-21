//
//  CoachProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol CoachProtocol {

    /// Add observer for Coach messages
    func addObserver(_ disposable: AnyObject, onShow: @escaping (CoachMessage) -> Void)

    /// Remove observer for Coach messages
    func removeObserver(_ disposable: AnyObject)

    /// Coach listener instance
    func coachListener() -> CoachListener

    /// Testing various messages sent by CoachManager
    func mockMessage(_ message: CoachMessage)
}
