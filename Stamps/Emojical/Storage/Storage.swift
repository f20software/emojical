//
//  Storage.swift
//  Stamps
//
//  Created by Alexander on 13.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Storage accessor. Works as compile-time DI.
public final class Storage {
    
    /// Application-wide data provider instance.
    static var shared: DataProvider! {
        willSet {
            if shared != nil {
                assertionFailure("Data provider should be initialized once per application launch")
            }
        }
    }
    
    /// Prevent instancing.
    private init() {}
}
