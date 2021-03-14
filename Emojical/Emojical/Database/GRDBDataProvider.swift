//
//  GRDBDataProvider.swift
//  Stamps
//
//  Created by Alexander on 13.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// GRDB-based data provider.
class GRDBDataProvider: DataProvider {
    
    private var dataSource: DataSource
    
    var repository: DataRepository {
        return dataSource
    }
    
    init(app: UIApplication) {
        dataSource = DataSource()
        try! dataSource.setupDatabase(app)
        // WARNING! - Will override database from a json backup file
        // dataSource.importDatabase(from: dataSource.localBackupFileName)
    }
    
    func awardsListener() -> AwardsListener {
        AwardsDataSourceListener(source: dataSource)
    }
    
    func goalsListener() -> GoalsListener {
        GoalsDataSourceListener(source: dataSource)
    }
    
    func stampsListener() -> StampsListener {
        StampsDataSourceListener(source: dataSource)
    }
    
    func diaryListener() -> DiaryListener {
        DiaryDataSourceListener(source: dataSource)
    }

}
