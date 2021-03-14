//
//  AwardsDataSourceListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

class CoachListener {
    
    // MARK: - Private properties.
    
    private var source: CoachMessageManager
    
    // MARK: - Lifecycle.
    
    init(source: CoachMessageManager) {
        self.source = source
    }
    
    func startListening(onShow: @escaping (CoachMessage) -> Void) {
        source.addValetObserver(self, onShow: { (message) in
            onShow(message)
        })
    }
    
    func stopListening() {
        source.removeValetObserver(self)
    }
}
