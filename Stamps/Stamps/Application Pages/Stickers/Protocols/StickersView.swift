//
//  StickersView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickersView: AnyObject {

    // MARK: - Updates

    /// Load stats for the month
    func loadData(stickers: [Stamp], goals: [Goal])
}
