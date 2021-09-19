//
//  ChartsPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol ChartsPresenterProtocol: AnyObject {
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
}
