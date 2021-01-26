//
//  GoalCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/23/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalCoordinatorProtocol: AnyObject {

    /// Select stickers for goal
    func selectStickers(_ selectedStickersIds: [Int64], onChange: @escaping ([Int64]) -> Void)
    
    func createSticker()
}
