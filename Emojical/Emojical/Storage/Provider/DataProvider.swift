//
//  DataProvider.swift
//  Stamps
//
//  Created by Alexander on 13.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Gives access to all data-related operational interfaces.
protocol DataProvider: class {
    
    /// Repository to query and save entities.
    var repository: DataRepository { get }
    
    /// Returns a new instance of Award entity listener.
    func awardsListener() -> AwardsListener
    
    /// Returns a new instance of Goal entity listener.
    func goalsListener() -> GoalsListener
    
    /// Returns a new instance of Stamp entity listener.
    func stampsListener() -> StampsListener

    /// Returns a new instance of Diary entity listener.
    func diaryListener() -> DiaryListener
}
