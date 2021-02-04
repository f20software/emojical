//
//  DataSource+Param.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//
import Foundation
import GRDB

// MARK: - Diary Helper Methods
extension DataSource {

    private static let lastWeekUpdateParam = "week-last-update"
    private static let lastMonthUpdateParam = "month-last-update"
    
    var lastWeekUpdate: Date? {
        get {
            return readDateParam(DataSource.lastWeekUpdateParam)
        }
        set {
            saveDateParam(DataSource.lastWeekUpdateParam, value: newValue)
        }
    }

    var lastMonthUpdate: Date? {
        get {
            return readDateParam(DataSource.lastMonthUpdateParam)
        }
        set {
            saveDateParam(DataSource.lastMonthUpdateParam, value: newValue)
        }
    }

    // Helper method to read data parameter by name
    private func readDateParam(_ name: String) -> Date? {
        do {
            let dateStr = try dbQueue.read { db -> String? in
                let request = StoredParam
                    .filter(StoredParam.Columns.name == name)
                let param = try request.fetchOne(db)
                return param?.value
            }
            if dateStr != nil {
                return Date(yyyyMmDd: dateStr!)
            }
        }
        catch { }
        return nil
    }
    
    // Helper method to read data parameter by name
    private func saveDateParam(_ name: String, value: Date?) {
        guard value != nil else { return }
        var param = StoredParam(name: name, value: value!.databaseKey)
        
        do {
            try dbQueue.write { db in
                try StoredParam.filter(StoredParam.Columns.name == name).deleteAll(db)
                try param.insert(db)
            }
        }
        catch { }
    }
    
    // Delete all stamps from the database
    func deleteAllParams() {
        do {
            _ = try dbQueue.write { db in
                try StoredParam.deleteAll(db)
            }
        }
        catch { }
    }

}
