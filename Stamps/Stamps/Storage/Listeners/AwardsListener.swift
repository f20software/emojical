//
//  AwardsListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol AwardsListener {
    func startListening(onChange: @escaping () -> Void)
}
