//
//  DataStorage.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

protocol DataRepository: class {
    
    // MARK: - Settings
    
    /// Last date when weekly goals has been updated
    var lastWeekUpdate: Date? { get set }
    
    /// Last date when monthly goals has been updated
    var lastMonthUpdate: Date? { get set }
    
    /// Backup filename
    var deviceBackupFileName: URL { get }
    
    // MARK: - Querying
    
    /// Diary records filtered for specific date interval 
    func diaryForDateInterval(from: Date, to: Date) -> [Diary]
    
    /// Diary records filtered for specific date interval and  filtered by stampId
    func diaryForDateInterval(from: Date, to: Date, stampId: Int64) -> [Diary]

    /// Goals by period
    func goalsByPeriod(_ period: Period) -> [Goal]
    
    /// Awards for date interval
    func awardsForDateInterval(from: Date, to: Date) -> [Award]
    
    /// Stamp Ids for a day (will be stored in Diary table)
    func stampsIdsForDay(_ day: Date) -> [Int64]
    
    /// Stamps for a day
    func stampsFor(_ day: Date) -> [Stamp]

    /// Only favorites stamps - used in day view
    func favoriteStamps() -> [Stamp]
    
    /// Stamp with given ID
    func stampById(_ id: Int64?) -> Stamp?
    
    /// Retrieves list of monthly awards for a given time interval
    func monthlyAwardsForInterval(start: Date, end: Date) -> [Award]
    
    /// Retrieves list of weekly awards for a given time interval
    func weeklyAwardsForInterval(start: Date, end: Date) -> [Award]
    
    /// Collect all stamp labels by iterating through Ids stored in the goal object
    func stampLabelsFor(_ goal: Goal) -> [String]
    
    /// Date of the first diary entry
    func getFirstDiaryDate() -> Date?
    
    /// Date of the last diary entry
    func getLastDiaryDate() -> Date?
    
    /// Goal with specified ID
    func goalById(_ identifier: Int64) -> Goal?
    
    /// List of goals particular stamp is used in
    func goalsUsedStamp(_ stampId: Int64?) -> [Goal]
    
    /// All registered goals
    func allGoals(includeDeleted: Bool) -> [Goal]
    
    /// All created stamps
    func allStamps(includeDeleted: Bool) -> [Stamp]
    
    /// All awards
    func allAwards() -> [Award]
    
    // MARK: - Saving
    
    /// Save (update or create) a stamp
    @discardableResult func save(stamp: Stamp) throws -> Stamp
    
    /// Save (update or create) a goal
    @discardableResult func save(goal: Goal) throws -> Goal
    
    /// Add and remove awards
    func updateAwards(add: [Award], remove: [Award])
    
    /// Update array of stamps for a given day
    func setStampsForDay(_ day: Date, stamps: [Int64])
    
    // MARK: - Backup
    
    /// Saves database content to a specified file URL
    func backupDatabase(to file: URL) -> Bool
    
    // MARK: - Maintenance
    
    /// Delete all records from the database
    func clearDatabase()
    
    /// Create demo database entires
    func createDemoEntries(from date: Date)
    
    /// Find stamp by its label (returns first matching or nil
    func stampByLabel(label: String) -> Stamp?
}

extension DataRepository {
    func allStamps() -> [Stamp] {
        allStamps(includeDeleted: false)
    }
    
    func allGoals() -> [Goal] {
        allGoals(includeDeleted: false)
    }
}
