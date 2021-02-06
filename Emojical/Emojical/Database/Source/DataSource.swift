//
//  DataSource.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import GRDB

/// GRDB data storage wrapper.
class DataSource {

    /// List of observers for awards change notification
    internal var awardsOnChangeObservers = ObserverList<(() -> Void)>()
    
    /// Internal queue to ensure that work with observers is done in a thread safe way
    internal var queue: DispatchQueue!

    /// Database queue.
    internal var dbQueue: DatabaseQueue!
    
    /// Initializes database.
    func setupDatabase(_ application: UIApplication) throws {

        queue = DispatchQueue(label: "com.svidersky.Emojical.datasource")

        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        dbQueue = try AppDatabase.openDatabase(atPath: databaseURL.path)
        
        // Be a nice iOS citizen, and don't consume too much memory
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#memory-management
        dbQueue.setupMemoryManagement(in: application)
    }
}
