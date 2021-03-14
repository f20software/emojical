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
    
    /// Dismiss button tapped  stickers changed
    var onDismiss: (() -> Void)? { get set }

    /// Review button tapped  stickers changed
    var onReview: (() -> Void)? { get set }

    // MARK: - Updates

    /// Loads awards  data
    func loadData(data: RecapReadyData)
}
