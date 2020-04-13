//
//  DTTableCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

// Base abstract QPTableCell class
class DTTableCell: NSObject {
    
    var icon: UIImage?
    
    // Text to be shown on the main cell label (left side)
    var text: String?
    
    var hidden: Bool = false

    // If user interaction is enabled (if false - cell becomes essentially read only)
    var isUserInteractionEnabled: Bool = true
    
    // Show/hide disclosure indicator
    var disclosureIndicator: Bool = false
    
    var indentationLevel: Int = 0

    // Private reference to associated UITableViewCell object instance
    fileprivate var _cell: UITableViewCell?
    
    // Weak reference to the table section
    weak var ownerSection: DTTableViewSection?
    
    // Weak reference to the table view model
    weak var ownerTableViewModel: DTTableViewModel?

    init(text: String?) {
        self.text = text
    }
    
    // Is called from QPTableViewController once UI cell is created to
    // set data values from cell model to UI elements
    func loadValue() {
        _cell?.textLabel?.text = text
        if icon != nil {
            _cell?.imageView?.image = icon
        }
    }
    
    func createCell(with identifier: String) -> UITableViewCell {
        _cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        _cell?.textLabel?.text = "NOT IMPLEMENTED"
        return _cell!
    }
    
    func applyStyle() {
        guard let cell = _cell else { return }
        
        // QuadPoint specific style
        cell.backgroundColor = DTStyle.themeColor(.backgroundColor)
        cell.textLabel?.textColor = DTStyle.themeColor(.alternateTextColor)
        cell.detailTextLabel?.textColor = DTStyle.themeColor(.textColor)

        // General table view styles
        cell.selectionStyle = .none
        cell.indentationLevel = self.indentationLevel
        cell.isUserInteractionEnabled = isUserInteractionEnabled

        if disclosureIndicator {
            cell.accessoryType = .disclosureIndicator
        }
    }

    // Will be called from QPTableViewController when cell is selected
    func didSelectRow(at indexPath: IndexPath, viewController: UIViewController) {
        // Call application handler if set
        didSelect?(self, indexPath)
    }
    
    // --- Cell action handlers
    
    // Cell was selected
    var didSelect: ((_ cell: DTTableCell, _ indexPath: IndexPath) -> Void)?
    
    // Associated value has changed
    var valueChanged: ((_ cell: DTTableCell) -> Void)?
}

// Simple readolny label cell
// --- [ Text: Label ]
class DTLabelCell: DTTableCell {
    
    var boundObject: AnyObject?
    var boundProperty: String?

    var detailText: String?
    
    init(text: String?, value: String? = nil) {
        super.init(text: text)
        self.detailText = value
    }
    
    init(text: String?, boundObject: AnyObject, boundProperty: String) {
        super.init(text: text)
        self.boundObject = boundObject
        self.boundProperty = boundProperty
    }

    override func loadValue() {
        super.loadValue()
        
        if boundObject != nil && boundProperty != nil {
            _cell?.detailTextLabel?.text = boundObject!.value(forKey: boundProperty!) as? String
        }
        else {
            _cell?.detailTextLabel?.text = detailText
        }
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        applyStyle()
        return _cell!
    }
}

// Button cell with just single main label displayed and optionally an icon
// --- [ Text ]
class DTButtonCell: DTTableCell {
    
    init(text: String?, icon: UIImage? = nil) {
        super.init(text: text)
        self.icon = icon
    }

    override func applyStyle() {
        super.applyStyle()
        // Unlilke other cells - main label color should be primary text colors
        // (in other cell text label uses alternativeTextColor and detail text label
        // uses primary text color)
        _cell?.textLabel?.textColor = DTStyle.themeColor(.textColor)
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        // QPLabelCell - using default style - [Text]
        _cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        applyStyle()
        return _cell!
    }
}

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
    
    // Reference to UISwitch created in cell
    var segmentedControl: UISegmentedControl?
    
    init(text: String?, boundObject: AnyObject, boundProperty: String, items: [String]) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        self.segmentedControlValues = items
        super.init(text: text)
    }

    override func loadValue() {
        super.loadValue()
        segmentedControl?.selectedSegmentIndex = boundObject.value(forKey: boundProperty) as? Int ?? 0
    }
    
    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        segmentedControl = UISegmentedControl.init(items: [segmentedControlValues])
        segmentedControl?.tintColor = DTStyle.themeColor(.tintColor)
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl?.isUserInteractionEnabled = isUserInteractionEnabled
        _cell?.accessoryView = segmentedControl
        applyStyle()

        return _cell!
    }
    
    @objc func segmentedControlValueChanged(sender: UISegmentedControl) {
        // Update bound object and call cell handler if set
        boundObject.setValue(NSNumber(value: sender.selectedSegmentIndex), forKey: boundProperty)
        valueChanged?(self)
    }
}

// Date/time selection cell
// --- [ Text: Date/Time ]
class DTDateCell: DTTableCell {
    
    var boundObject: AnyObject
    var boundProperty: String
    
    // Formatter that will be used to display date/time bound object value
    var dateFormatter: DateFormatter

    init(text: String?, boundObject: AnyObject, boundProperty: String) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        self.dateFormatter = DateFormatter.init()
        super.init(text: text)
    }

    override func loadValue() {
        super.loadValue()
        if let value = boundObject.value(forKey: boundProperty) as? Date {
            _cell?.detailTextLabel?.text = dateFormatter.string(from: value)
        }
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        applyStyle()
        return _cell!
    }
}

// A cell with UITextField on the right side bound to an object value
// --- [ Text: [text] ]
class DTTextFieldCell: DTTableCell {
    
    var boundObject: AnyObject
    var boundProperty: String
    
    // References to the UI elements of actual cell
    var textLabel: UILabel?
    var textField: UITextField?

    // Cell options specific to text field cells
    var textAlignment: NSTextAlignment = .right
    
    // string representation of our copy of the object property
    // var value: String?
    
    init(text: String?, boundObject: AnyObject, boundProperty: String) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        super.init(text: text)
    }

    override func loadValue() {
        // Don't need to call super because this cell is loaded from xib file
        // and have custom UI elements for textLabel and textField
        // super.getData(to: cell)
        // value = boundObject.value(forKey: boundProperty) as? String
        textLabel?.text = self.text
        textField?.text = boundObject.value(forKey: boundProperty) as? String
    }
    
    override func applyStyle() {
        super.applyStyle()

        textLabel?.textColor = DTStyle.themeColor(.alternateTextColor)
        textField?.textColor = DTStyle.themeColor(.textColor)
        textField?.backgroundColor = DTStyle.themeColor(.backgroundColor)
        textField?.tintColor = DTStyle.themeColor(.tintColor)
        textField?.textAlignment = textAlignment
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = Bundle.main.loadNibNamed("QPTableViewCell-Text", owner: self, options: nil)?.first as? UITableViewCell

        // Store refs to UI elements
        textLabel = _cell?.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel
        textField = _cell?.contentView.subviews.first(where: { $0 is UITextField }) as? UITextField

        applyStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: textField)

        return _cell!
    }
    
    // Will be called from QPTableViewController when cell is selected
    override func didSelectRow(at indexPath: IndexPath, viewController: UIViewController) {
        super.didSelectRow(at: indexPath, viewController: viewController)
        // Special handler of making sure textField is focused when user tapped
        // anywhere on the cell
        DispatchQueue.main.async {
            self.textField?.becomeFirstResponder()
        }
    }

    @objc func textDidChange(sender: NSNotification) {
        // value = textField?.text
        boundObject.setValue(textField?.text, forKey: boundProperty)
        valueChanged?(self)
    }
}

// A cell with UITextField on the right side bound to an object numeric value
// --- [ Text: [number] ]
class DTNumericTextFieldCell: DTTextFieldCell {
    
    // var numericValue: NSNumber?
    
    // Controlling min and max numeric value 
    var minimumValue: NSNumber?
    var maximumValue: NSNumber?

    override func loadValue() {
        // super.getData(to: cell)
        textLabel?.text = self.text
        let numericValue = boundObject.value(forKey: boundProperty) as? NSNumber
        textField?.text = numericValue?.stringValue
    }
    
    @objc override func textDidChange(sender: NSNotification) {
        let nf = NumberFormatter()
        let numericValue = nf.number(from: textField?.text ?? "")
        boundObject.setValue(numericValue, forKey: boundProperty)
        valueChanged?(self)
    }
}

// A cell displaying current value selected from the list
// --- [ Text: Current Value > ]
class DTSelectionCell: DTTableCell {
    
    var boundObject: AnyObject
    
    // We can either bound selected value by name or by its index
    var boundProperty: String?
    var boundIndexProperty: String?
    
    // List of items with possible values
    var selectionItems: [String]
    
    // Currently selected item (nil if nothing is selected)
    var selectedItemIndex: Int?
    
    // Controlling behavior of detail selection list
    var autoDismissDetailView: Bool = true

    init(text: String?, boundObject: AnyObject, boundProperty: String, items: [String]) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        self.selectionItems = items
        super.init(text: text)
    }

    init(text: String?, boundObject: AnyObject, boundIndexProperty: String, items: [String]) {
        self.boundObject = boundObject
        self.boundIndexProperty = boundIndexProperty
        self.selectionItems = items
        super.init(text: text)
    }

    override func loadValue() {
        super.loadValue()
        
        if boundProperty != nil {
            let valueText = boundObject.value(forKey: boundProperty!) as? String
            _cell?.detailTextLabel?.text = valueText
            if valueText != nil {
                selectedItemIndex = selectionItems.firstIndex(of: valueText!)
            }
        }
        else if boundIndexProperty != nil {
            selectedItemIndex = boundObject.value(forKey: boundIndexProperty!) as? Int ?? 0
            let valueText = selectionItems[selectedItemIndex!]
            _cell?.detailTextLabel?.text = valueText
        }
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        applyStyle()
        // Always display disclosure indicator for selection cells
        _cell?.accessoryType = .disclosureIndicator
        return _cell!
    }

    // Will be called from QPTableViewController when cell is selected
    override func didSelectRow(at indexPath: IndexPath, viewController: UIViewController) {
        let detailVC = DTTableSelectionViewController.init(style: .plain)
        
        detailVC.items = selectionItems
        detailVC.title = text
        detailVC.delegate = self
        if boundProperty != nil {
            detailVC.currentValue = boundObject.value(forKey: boundProperty!) as? String
        }
        else if boundIndexProperty != nil {
            selectedItemIndex = boundObject.value(forKey: boundIndexProperty!) as? Int ?? 0
            detailVC.currentValue = selectionItems[selectedItemIndex!]
        }
        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension DTSelectionCell: DTTableSelectionViewControllerDelegate {
    
    // Whenever value is selected in the detail view - we need to do the following:
    // - update bound object value and notify caller that it changed
    // - update our own UI with new value
    // - see if need to dismiss detail view controller
    @objc func valueSelected(viewController: UIViewController, value: String) {

        if boundProperty != nil {
            boundObject.setValue(value, forKey: self.boundProperty!)
        }
        else if boundIndexProperty != nil {
            selectedItemIndex = selectionItems.firstIndex(of: value)
            boundObject.setValue(selectedItemIndex, forKey: self.boundIndexProperty!)
        }
        
        valueChanged?(self)
        loadValue()
        if autoDismissDetailView {
            viewController.navigationController?.popViewController(animated: true)
        }
    }
}
