//
//  OptionsPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/29/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol OptionsPresenterProtocol: NSObject {
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
}
