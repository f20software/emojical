//
//  SelectStickersPresenterProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/23/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol SelectStickersPresenterProtocol: AnyObject {
    
    // MARK: - Callbacks
    
    /// Selected stickers changed
    var onChange: (([Int64]) -> Void)? { get set }

    // MARK: - View lifecycle
    
    /// Called when view finished initial loading
    func onViewDidLoad()

    /// Called when view about to appear on the screen
    func onViewWillAppear()
}
