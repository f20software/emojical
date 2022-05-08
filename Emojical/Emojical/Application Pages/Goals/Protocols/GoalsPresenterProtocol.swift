//
//  GoalsPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalsPresenterProtocol: AnyObject {
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
}
