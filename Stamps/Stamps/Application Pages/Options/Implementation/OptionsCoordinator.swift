//
//  OptionsCoordinator.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/29/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class OptionsCoordinator: OptionsCoordinatorProtocol {
    
    // MARK: - DI

    private weak var parentController: UINavigationController?

    init(
        parent: UINavigationController)
    {
        self.parentController = parent
    }

    /// Navigate to Developer Options
    func developerOptions() {
        
    }

    // MARK: - Private helpers
    
}
