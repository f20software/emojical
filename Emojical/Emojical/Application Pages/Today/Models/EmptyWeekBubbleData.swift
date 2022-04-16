//
//  EmptyWeekBubbleData.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 04/16/2022.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// Data we need to display empty week bubble 
struct EmptyWeekBubbleData {
    
    /// Message to be displayed
    let message: String
    
    /// Image to be displayed on the top
    let faceImage: UIImage
}

extension EmptyWeekBubbleData: Equatable {}
