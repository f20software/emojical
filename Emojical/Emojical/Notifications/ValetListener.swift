//
//  AwardsDataSourceListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

class ValetListener {
    
    // MARK: - Private properties.
    
    private var source: ValetManager
    
    // MARK: - Lifecycle.
    
    init(source: ValetManager) {
        self.source = source
    }
    
    func startListening(onShow: @escaping (ValetMessage) -> Void) {
        source.addValetObserver(self, onShow: { (message) in
            onShow(message)
        })
    }
    
    func stopListening() {
        source.removeValetObserver(self)
    }
}
