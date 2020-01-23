//
//  Stamp.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit


class Stamp {
    
    let id: Int
    let name: String
    let label: String
    let color: UIColor
    let favorite: Bool
    
    init(id: Int, label: String, name: String, color: UIColor, favorite: Bool) {
        self.id = id
        self.name = name
        self.label = label
        self.color = color
        self.favorite = favorite
    }
}
