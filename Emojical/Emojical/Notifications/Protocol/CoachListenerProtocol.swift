//
//  CoachListenerProtocol.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol CoachListenerProtocol {

    /// Start listening for Coach messages
    func startListening(onShow: @escaping (CoachMessage) -> Void)
    
    /// Stop listening for Coach messages
    func stopListening()
}
