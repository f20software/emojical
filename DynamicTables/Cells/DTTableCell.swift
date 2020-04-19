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
    var _cell: UITableViewCell?

    // Reference to UI element of actual cell
    var textLabel: UILabel?
    var detailTextLabel: UILabel?
    var iconView: UIImageView?

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
        textLabel?.text = text
        if icon != nil {
            _cell?.imageView?.image = icon
            iconView = _cell?.imageView
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
        textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel?.textColor = DTStyle.themeColor(.alternateTextColor)
        detailTextLabel?.textColor = DTStyle.themeColor(.textColor)

        // General table view styles
        cell.backgroundColor = DTStyle.themeColor(.backgroundColor)
        // cell.contentView.backgroundColor = DTStyle.themeColor(.backgroundColor)
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
    
    // Cell was created
    var cellCreated: ((_ cell: DTTableCell) -> Void)?
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
            detailTextLabel?.text = boundObject!.value(forKey: boundProperty!) as? String
        }
        else {
            detailTextLabel?.text = detailText
        }
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = Bundle.main.loadNibNamed("DTTableViewCell-Label", owner: self, options: nil)?.first as? UITableViewCell

        // Store refs to UI elements
        textLabel = _cell?.contentView.subviews[0] as? UILabel
        detailTextLabel = _cell?.contentView.subviews[1] as? UILabel
        applyStyle()
        return _cell!
    }
}

// Button cell with just single main label displayed and optionally an icon
// --- [ Text ]
class DTButtonCell: DTTableCell {
    
    var textColor: UIColor = DTStyle.themeColor(.redColor)
    
    init(text: String?, icon: UIImage? = nil) {
        super.init(text: text)
        self.icon = icon
    }

    override func applyStyle() {
        super.applyStyle()
        textLabel?.textColor = textColor
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        // Using default style - [Text]
        _cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        textLabel = _cell?.textLabel
        _cell?.selectionStyle = .default
        applyStyle()
        return _cell!
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

// Custom cell from the .xib file that application provided
// --- [  ]
class DTCustomCell: DTTableCell {
    
    var xibFile: String
    
    init(xibFile: String) {
        self.xibFile = xibFile
        super.init(text: nil)
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = Bundle.main.loadNibNamed(xibFile, owner: self, options: nil)?.first as? UITableViewCell
        applyStyle()
        cellCreated?(self)
        return _cell!
    }
}
