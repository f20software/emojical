//
//  StickersPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickersPresenterProtocol: AnyObject {
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
}
