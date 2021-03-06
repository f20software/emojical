//
//  DiaryDataSourceListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

class DiaryDataSourceListener: DiaryListener {
    
    // MARK: - Private properties.
    
    private var observer: TransactionObserver?
    private var source: DataSource
    
    // MARK: - Lifecycle.
    
    init(source: DataSource) {
        self.source = source
    }
    
    func startListening(onChange: @escaping (Int) -> Void) {
        let request = StoredDiary.orderedByDate()
        let observation = ValueObservation.tracking { db in
            try request.fetchAll(db).count
        }
        observer = observation.start(
            in: source.dbQueue,
            onError: { _ in
                //
            },
            onChange: { count in
                onChange(count)
            }
        )
    }
}
