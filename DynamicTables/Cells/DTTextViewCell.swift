//
//  DTTableCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

// Readonly cell with multiline text
// --- [ Loren ipsum... ]
class DTTextViewCell: DTTableCell {
    
    override init(text: String?) {
        super.init(text: text)
    }
    
    init(text: String?, boundObject: AnyObject, boundProperty: String) {
        super.init(text: text)
    }

    override func loadValue() {
        // super.loadValue()
        textLabel?.text = text
    }

    override func applyStyle() {
        super.applyStyle()
        textLabel?.textColor = DTStyle.themeColor(.textColor)
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = Bundle.main.loadNibNamed("DTTableViewCell-TextView", owner: self, options: nil)?.first as? UITableViewCell

        // Store refs to UI elements
        textLabel = _cell?.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel
        applyStyle()
        
        return _cell!
    }
}

