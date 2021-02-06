//
//  RecapPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/25/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Awards Recap presenter protocol
protocol RecapPresenterProtocol: AnyObject {
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
}
