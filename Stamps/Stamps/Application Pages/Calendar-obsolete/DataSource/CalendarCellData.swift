//
//  CalendarCell.swift
//  Stamps
//
//  Created by Alexander on 16.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct StickerData {
    let label: String
    let color: UIColor
}

extension StickerData: Equatable, Hashable {}

enum CalendarCellData {
    case header(title: String, monthlyAwards: [Award], weeklyAwards: [Award])
    case compactWeek(labels: [String], data: [[UIColor]], awards: [UIColor])
    case expandedWeek(labels: [String], data: [[StickerData]], awards: [UIColor])
}
