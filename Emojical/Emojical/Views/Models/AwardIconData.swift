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
    let goalId: Int64?
    let emoji: String?
    let backgroundColor: UIColor
    let borderColor: UIColor
    let reached: Bool
}

extension AwardIconData {
    
    // Convinience constructor from Stamp object
    init(goal: Goal, busted: Bool = false) {
        
        if busted {
            self.init(
                goalId: goal.id,
                emoji: goal.stickers.first?.label,
                backgroundColor: Theme.main.colors.unreachedGoalBackground,
                borderColor: UIColor.clear,
                reached: false
            )
        } else {
            self.init(
                goalId: goal.id,
                emoji: goal.stickers.first?.label,
                backgroundColor: (goal.stickers.first?.color ?? Theme.main.colors.tint).withAlphaComponent(0.5),
                borderColor: Theme.main.colors.reachedGoalBorder,
                reached: true
            )
        }
    }
}

extension AwardIconData: Equatable, Hashable {}
