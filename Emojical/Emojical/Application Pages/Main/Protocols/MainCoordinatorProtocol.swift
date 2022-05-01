//
//  MainCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/8/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

enum Page {
    case goals
    case stickers
    case today
    case stats
    case options
}

protocol MainCoordinatorProtocol: AnyObject {

    /// Navigate to specific page
    func navigateTo(_ page: Page)
}
