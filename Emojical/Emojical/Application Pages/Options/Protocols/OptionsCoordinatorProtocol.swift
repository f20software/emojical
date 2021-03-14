//
//  OptionsCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/29/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol OptionsCoordinatorProtocol: AnyObject {

    /// Navigate to Developer Options
    func developerOptions(main: MainCoordinatorProtocol?)
}
