//
//  DTTableCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

// A cell with UISwitchControl on the right side bound to an object value
// --- [ Text: [ON/OFF] ]
class DTSwitchCell: DTTableCell {
    
    var boundObject: AnyObject
    var boundProperty: String
    
    // Reference to UISwitch created in cell
    var switchControl: UISwitch?
    
    init(text: String?, boundObject: AnyObject, boundProperty: String) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        super.init(text: text)
    }

    override func loadValue() {
        super.loadValue()
        switchControl?.isOn = boundObject.value(forKey: boundProperty) as? Bool ?? false
    }
    
    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        switchControl = UISwitch.init(frame: CGRect.zero)
        switchControl?.tintColor = DTStyle.themeColor(.tintColor)
        switchControl?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        switchControl?.isUserInteractionEnabled = isUserInteractionEnabled
        _cell?.accessoryView = switchControl
        applyStyle()

        return _cell!
    }
    
    @objc func switchValueChanged(sender: UISwitch) {
        // Update bound object and call cell handler if set
        boundObject.setValue(NSNumber(booleanLiteral: sender.isOn), forKey: boundProperty)
        valueChanged?(self)
    }
}

// A cell with UISegmentedControl on the right side bound to an object value
// --- [ Text: [Option1/Option2] ]
class DTSegmentedControlCell: DTTableCell {
    
    var boundObject: AnyObject
    var boundProperty: String
    var segmentedControlValues: [String]
    
    // References to the UI elements of actual cell
    var segmentedControl: UISegmentedControl?
    
    init(text: String?, boundObject: AnyObject, boundProperty: String, items: [String]) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        self.segmentedControlValues = items
        super.init(text: text)
    }

    override func loadValue() {
        // super.loadValue()
        textLabel?.text = self.text
        segmentedControl?.selectedSegmentIndex = boundObject.value(forKey: boundProperty) as? Int ?? 0
    }
    
    override func applyStyle() {
        super.applyStyle()

        textLabel?.textColor = DTStyle.themeColor(.alternateTextColor)
        segmentedControl?.tintColor = DTStyle.themeColor(.tintColor)
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = Bundle.main.loadNibNamed("DTTableViewCell-Segmented", owner: self, options: nil)?.first as? UITableViewCell

        // Store refs to UI elements
        textLabel = _cell?.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel
        segmentedControl = _cell?.contentView.subviews.first(where: { $0 is UISegmentedControl }) as? UISegmentedControl
        segmentedControl?.removeAllSegments()
        for item in segmentedControlValues {
            segmentedControl?.insertSegment(withTitle: item, at: segmentedControl?.numberOfSegments ?? 0, animated: false)
        }
        segmentedControl?.isUserInteractionEnabled = isUserInteractionEnabled
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)

        applyStyle()
        return _cell!
    }
    
    @objc func segmentedControlValueChanged(sender: UISegmentedControl) {
        // Update bound object and call cell handler if set
        boundObject.setValue(NSNumber(value: sender.selectedSegmentIndex), forKey: boundProperty)
        valueChanged?(self)
    }
}
