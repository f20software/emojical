//
//  ChartsView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol ChartsView: AnyObject {

    /// User tapped on selected chart
    var onChartTapped: ((Int) -> Void)? { get set }

    // MARK: - Updates

    /// Update page title
    func updateTitle(_ text: String)

    /// Load list of charts
    func loadChartsData(data: [ChartTypeDetails])
}
