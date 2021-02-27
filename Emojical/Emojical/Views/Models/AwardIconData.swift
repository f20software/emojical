//
//  AwardIconData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/13/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// View model to show Award icon
struct AwardIconData {
    let emoji: String?
    let backgroundColor: UIColor
    let borderColor: UIColor
}

extension AwardIconData {
    
    // Convinience constructor from Stamp object
    init(stamp: Stamp?) {
        self.init(
            emoji: stamp?.label,
            backgroundColor: (stamp?.color ?? Theme.main.colors.tint).withAlphaComponent(0.5),
            borderColor: Theme.main.colors.reachedGoalBorder
        )
    }
}

extension AwardIconData: Equatable, Hashable {}
