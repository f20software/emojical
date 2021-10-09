//
//  ChartsCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol ChartsCoordinatorProtocol: AnyObject {

    /// Push to show specific chart
    func showChart(_ chart: ChartType)
}
