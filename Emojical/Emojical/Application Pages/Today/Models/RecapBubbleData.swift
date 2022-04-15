//
//  RecapBubbleData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 04/11/2022.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// Data we need to display recap bubble at the bottom
struct RecapBubbleData {
    
    /// Message to be displayed
    let message: String
    
    /// List of award icons (could be emtpy)
    let icons: [AwardIconData]
    
    /// Image to be displayed on the top
    let faceImage: UIImage
}

extension RecapBubbleData: Equatable {}
