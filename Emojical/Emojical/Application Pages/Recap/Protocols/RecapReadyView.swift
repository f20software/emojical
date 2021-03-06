//
//  RecapReadyView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol RecapReadyView: AnyObject {

    // MARK: - Callbacks
    
    /// Dismissing view button tapped. True will be passed when Review is tapped
    var onDismiss: ((Bool) -> Void)? { get set }

    // MARK: - Updates

    /// Loads awards  data
    func loadData(data: RecapReadyData)
}
