//
//  AwardsDataSourceListener.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

class CoachListener: CoachListenerProtocol {
    
    // MARK: - Private properties.
    
    private var source: CoachProtocol
    
    // MARK: - Lifecycle
    
    init(source: CoachProtocol) {
        self.source = source
    }
    
    /// Start listening for Coach messages
    func startListening(onShow: @escaping (CoachMessage) -> Void) {
        source.addObserver(self, onShow: { (message) in
            onShow(message)
        })
    }
    
    /// Stop listening for Coach messages
    func stopListening() {
        source.removeObserver(self)
    }
}
