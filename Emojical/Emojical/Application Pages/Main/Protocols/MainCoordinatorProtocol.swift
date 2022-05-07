//
//  MainCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/8/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol MainCoordinatorProtocol: AnyObject {

    /// Navigate to specific page
    func navigateTo(_ page: Page)
}
