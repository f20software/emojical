//
//  RecapBubbleData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 04/11/2022.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Data we need to display recap bubble at the bottom
struct RecapBubbleData {
    let message: String
    let icons: [AwardIconData]
}

extension RecapBubbleData: Equatable {}
