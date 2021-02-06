//
//  AwardsDataSourceListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

class AwardsDataSourceListener: AwardsListener {
    
    // MARK: - Private properties.
    
    private var source: DataSource
    
    // MARK: - Lifecycle.
    
    init(source: DataSource) {
        self.source = source
    }
    
    func startListening(onChange: @escaping () -> Void) {
        source.addAwardsObserver(self, onChange: {
            onChange()
        })
    }
}
