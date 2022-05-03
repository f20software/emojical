//
//  MainCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/8/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

// If you re-arragned pages in the Main storyboard - make sure to update this enum
// with proper indecies 
enum Page: Int {
    case today = 0
    case goals = 1
    case stickers = 2
    case stats = 3
    case options = 4
}

protocol MainCoordinatorProtocol: AnyObject {

    /// Navigate to specific page
    func navigateTo(_ page: Page)
}
