//
//  Page.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/7/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Enum reflecting all pages in the MainViewController.
/// If you re-arragned pages in the Main storyboard - make sure to update this enum  with proper indecies
enum Page: Int {
    case today = 0
    case goals = 1
    case stickers = 2
    case stats = 3
    case options = 4
}
