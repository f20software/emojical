//
//  WelcomePresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/28/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Congratulation Screen presenter protocol
protocol WelcomePresenterProtocol: AnyObject {
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
}
