//
//  TodayCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/11/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol TodayCoordinatorProtocol: AnyObject {

    /// Shows modal form to create new sticker
    func newSticker()

    /// Navigates to goals / awards recap window
    func showAwardsRecap(data: [AwardRecapData])
}
