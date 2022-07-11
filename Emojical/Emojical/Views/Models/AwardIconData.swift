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

extension Award {

    /// Conviniece method to create Icon data based on award status
    func toIconData() -> AwardIconData {
        if reached {
            return AwardIconData(
                goalId: goalId,
                emoji: label,
                backgroundColor: (backgroundColor ?? Theme.main.colors.tint).withAlphaComponent(0.5),
                borderColor: Theme.main.colors.reachedGoalBorder,
                reached: reached
            )
        } else {
            return AwardIconData(
                goalId: goalId,
                emoji: label,
                backgroundColor: Theme.main.colors.unreachedGoalBackground,
                borderColor: UIColor.clear,
                reached: reached
            )
        }
    }
}

extension Goal {

    /// Conviniece method to create Icon data based on when goal will be reached
    func toAwardIconData() -> AwardIconData {
        return AwardIconData(
            goalId: id,
            emoji: stickers.first?.label,
            backgroundColor: (stickers.first?.color ?? Theme.main.colors.tint).withAlphaComponent(0.5),
            borderColor: Theme.main.colors.reachedGoalBorder,
            reached: true
        )
    }
}

extension AwardIconData: Equatable, Hashable {}
