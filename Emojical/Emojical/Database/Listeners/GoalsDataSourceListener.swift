//
//  GoalsDataSourceListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

class GoalsDataSourceListener: GoalsListener {
    
    // MARK: - Private properties.
    
    private var observer: TransactionObserver?
    private var source: DataSource
    
    // MARK: - Lifecycle.
    
    init(source: DataSource) {
        self.source = source
    }
    
    func startListening(onError: @escaping (Error) -> Void, onChange: @escaping () -> Void) {
        let request = StoredGoal.orderedByPeriodName()
        let observation = ValueObservation.tracking { db in
            try request.fetchAll(db)
        }
        observer = observation.start(
            in: source.dbQueue,
            onError: onError,
            onChange: { _ in
                onChange()
            }
        )
    }
}
