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

    /// List of goals with their total / streaks numbers
    case goals
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
                title: "chart_title_monthly_stickers".localized,
                subTitle: "chart_subtitle_monthly_stickers".localized,
                icon: UIImage(systemName: imageName)
            )
            
        case .goals:
            var imageName = "waveform.path.ecg.rectangle"
            if #available(iOS 15.0, *) {
                imageName = "chart.xyaxis.line"
            }

            return ChartTypeDetails(
                title: "chart_title_goals".localized,
                subTitle: "chart_subtitle_goals".localized,
                icon: UIImage(systemName: imageName)
            )
        }

    }

    /// ViewControllerId to be mapped to storyboard Id
    var viewControllerId: String {
        switch self {
        case .monthlyStickers:
            return "MonthlyStickers"
        case .goals:
            return "GoalStreaks"
        }
    }
}
