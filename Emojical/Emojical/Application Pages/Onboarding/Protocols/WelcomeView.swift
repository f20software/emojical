//
//  WelcomeView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/28/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol WelcomeView: AnyObject {

    // MARK: - Callbacks
    
    /// Dismiss button tapped  stickers changed
    var onDismiss: (() -> Void)? { get set }

    // MARK: - Updates

    /// Loads awards  data
    func loadData(data: WelcomeData)
    
    /// Configure layout
    func setBottomMargin(margin: Float)
}
