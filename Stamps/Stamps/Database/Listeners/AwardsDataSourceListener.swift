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
    
    private var observer: TransactionObserver?
    private var source: DataSource
    
    // MARK: - Lifecycle.
    
    init(source: DataSource) {
        self.source = source
    }
    
    func startListening(onError: @escaping (Error) -> Void, onChange: @escaping ([Award]) -> Void) {
        let request = StoredAward.orderedByDateDesc()
        let observation = ValueObservation.tracking { db in
            try request.fetchAll(db)
        }
        observer = observation.start(
            in: source.dbQueue,
            onError: onError,
            onChange: { awards in
                onChange(awards.map { $0.toModel()})
            }
        )
    }
}
