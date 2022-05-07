//
//  NoGoalsData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/7/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct NoGoalsData {
    let icon: UIImage
    let instructions: String
    let buttonA: String
    let buttonB: String
}

extension NoGoalsData: Equatable, Hashable {}
