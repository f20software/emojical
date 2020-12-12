//
//  DTColorCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

// A cell with 7 buttons to select different color
// --- [ [] [] [] [] [] [] [] ]
class DTColorCell: DTTableCell, DTTableViewColorCellDelegate {
    
    var boundObject: AnyObject
    var boundProperty: String
    
    // Reference to UISwitch created in cell
    var switchControl: UISwitch?
    let colorValues: [String]
    
    init(text: String?, boundObject: AnyObject, boundProperty: String, colorValues: [String]) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        self.colorValues = colorValues
        super.init(text: text)
    }

    override func loadValue() {
        super.loadValue()
        
        if let color = boundObject.value(forKey: boundProperty) as? String,
            let index = colorValues.firstIndex(of: color) {
            (_cell as! DTTableViewColorCell).setSelectedIndex(index)
        }
        
        // switchControl?.isOn = boundObject.value(forKey: boundProperty) as? Bool ?? false
    }
    
    override func createCell(with identifier: String) -> UITableViewCell {
        let colorCell = Bundle.main.loadNibNamed("DTTableViewCell-Color", owner: self, options: nil)?.first as? DTTableViewColorCell

        colorCell?.setColors(colorValues, selectedIdx: -1)
        colorCell?.delegate = self
        applyStyle()
        _cell = colorCell
        return colorCell!
    }
    
    func colorSelected(_ colorIdx: Int) {
        boundObject.setValue(colorValues[colorIdx], forKey: boundProperty)
        valueChanged?(self)
    }
}
