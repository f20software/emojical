//
//  ChartType.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

enum ChartType: Int, Hashable {
    
    /// Monthly stats by sticker
    case monthlyStickers

    /// List of goals with their streaks
    case goalStreak
}

/// View model for detail information about chart type
struct ChartTypeDetails {
    
    /// Chart title
    let title: String?
    
    /// Chart subtitle
    let subTitle: String?
    
    /// Icon image
    let icon: UIImage?
}


/// Convinience properties
extension ChartType {
    
    /// Returns ChartTypeDetail view model based on ChartType
    func toDetailModel() -> ChartTypeDetails {
        switch self {
        case .monthlyStickers:
            var imageName = "square.grid.3x3"
            if #available(iOS 15.0, *) {
                imageName = "square.grid.3x3.middleright.filled"
            }
            
            return ChartTypeDetails(
                title: "Monthly Stickers",
                subTitle: "Sticker usage for a month",
                icon: UIImage(systemName: imageName)
            )
            
        case .goalStreak:
            var imageName = "waveform.path.ecg.rectangle"
            if #available(iOS 15.0, *) {
                imageName = "chart.xyaxis.line"
            }

            return ChartTypeDetails(
                title: "Goals Streaks",
                subTitle: "Goals stats and streaks",
                icon: UIImage(systemName: imageName)
            )
        }

    }

    /// ViewControllerId to be mapped to storyboard Id
    var viewControllerId: String {
        switch self {
        case .monthlyStickers:
            return "MonthlyStickers"
        case .goalStreak:
            return "GoalStreaks"
        }
    }
}
