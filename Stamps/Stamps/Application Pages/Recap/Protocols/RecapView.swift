//
//  RecapView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol RecapView: AnyObject {

    // MARK: - Updates

    /// Loads awards data
    func loadRecapData(data: [AwardRecapData])
}
