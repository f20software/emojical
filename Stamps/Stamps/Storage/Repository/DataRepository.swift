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
    
    /// Get color for an award. Currently we just check the goal this award was given for
    /// and get color of the first stamp on that goal
    func colorForAward(_ award: Award) -> UIColor
    
    /// Stamp Ids for a day (will be stored in Diary table)
    func stampsIdsForDay(_ day: Date) -> [Int64]
    
    /// Only favorites stamps - used in day view
    func favoriteStamps() -> [Stamp]
    
    /// Stamp with given ID
    func stampById(_ id: Int64) -> Stamp?
    
    /// Retrieve list of weekly awards given for the week with specific start and end dates
    func monthlyAwardsForInterval(start: Date, end: Date) -> [Award]
    
    /// Retrieve list of monthly awards given for the week with specific start and end dates
    func weeklyAwardsForInterval(start: Date, end: Date) -> [Award]
    
    /// Retrieve list of monthly awards given for the month of input date
    func monthlyAwardsForMonth(date: Date) -> [Award]
    
    /// Retrieve list of weekly awards given for the month of input date
    func weeklyAwardsForMonth(date: Date) -> [Award]
    
    /// Collect all stamp labels by iterating through Ids stored in the goal object
    func stampLabelsFor(_ goal: Goal) -> [String]
    
    /// Date of the first diary entry
    func getFirstDiaryDate() -> Date?
    
    /// Date of the last diary entry
    func getLastDiaryDate() -> Date?
    
    /// List of lists of awards grouped by the same month
    func awardsGroupedByMonth(_ awards: [Award]) -> [[Award]]
    
    /// Goal with specified ID
    func goalById(_ identifier: Int64) -> Goal?
    
    /// Get color for a goal. Currently we just check the goal this award was given for
    /// and get color of the first stamp on that goal
    func colorForGoal(_ goalId: Int64) -> UIColor
    
    /// List of goals particular stamp is used in
    func goalsUsedStamp(_ stampId: Int64) -> [Goal]
    
    /// All registered goals
    func allGoals(includeDeleted: Bool) -> [Goal]
    
    /// All created stamps
    func allStamps(includeDeleted: Bool) -> [Stamp]
    
    /// Last 10 awards
    func recentAwards() -> [Award]
    
    /// Names of stamps used at specific date
    func stampsNamesForDay(_ day: Date) -> [String]
    
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
}

extension DataRepository {
    func allStamps() -> [Stamp] {
        allStamps(includeDeleted: false)
    }
    
    func allGoals() -> [Goal] {
        allGoals(includeDeleted: false)
    }
}
