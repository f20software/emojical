//
//  GallerySticker.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/2/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

struct GallerySticker {
    var id: Int64?
    var name: String
    var label: String
    var color: UIColor
}

extension GallerySticker: Equatable, Hashable {}
