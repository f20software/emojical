//
//  ValetManagerProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol ValetManagerProtocol {

    /// Valet listener instance
    func valetListener() -> ValetListener

    /// Testing various messages sent by ValetManager
    func mockMessage(_ message: ValetMessage)
}
