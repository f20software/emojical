//
//  DTTableCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

// A cell with UITextField on the right side bound to an object value
// --- [ Text: [text] ]
class DTTextFieldCell: DTTableCell {
    
    var boundObject: AnyObject
    var boundProperty: String
    
    // References to the UI elements of actual cell
    var textField: UITextField?

    // Cell options specific to text field cells
    var textAlignment: NSTextAlignment = .left
    var autocapitalizationType: UITextAutocapitalizationType = .none
    
    // string representation of our copy of the object property
    // var value: String?
    
    init(text: String?, boundObject: AnyObject, boundProperty: String) {
        self.boundObject = boundObject
        self.boundProperty = boundProperty
        super.init(text: text)
    }

    override func loadValue() {
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
        textField?.autocapitalizationType = autocapitalizationType
    }

    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = Bundle.main.loadNibNamed("DTTableViewCell-TextField", owner: self, options: nil)?.first as? UITableViewCell

        // Store refs to UI elements
        textLabel = _cell?.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel
        textField = _cell?.contentView.subviews.first(where: { $0 is UITextField }) as? UITextField

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: textField)

        applyStyle()

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
        textField?.keyboardType = .decimalPad
    }
    
    @objc override func textDidChange(sender: NSNotification) {
        let nf = NumberFormatter()
        let numericValue = nf.number(from: textField?.text ?? "") ?? 0
        boundObject.setValue(numericValue, forKey: boundProperty)
        valueChanged?(self)
    }
}

// A cell with EmojiTextField on the right side bound to an object numeric value
// --- [ Text: [:)] ]
class DTEmojiTextFieldCell: DTTextFieldCell, UITextFieldDelegate {
    
    override func createCell(with identifier: String) -> UITableViewCell {
        _cell = Bundle.main.loadNibNamed("DTTableViewCell-Emoji", owner: self, options: nil)?.first as? UITableViewCell

        // Store refs to UI elements
        textLabel = _cell?.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel
        textField = _cell?.contentView.subviews.first(where: { $0 is EmojiTextField }) as? EmojiTextField
        textField?.delegate = self

        applyStyle()
        return _cell!
    }

    // Limit emoji text field to a single character
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = String(string.first ?? " ")
        boundObject.setValue(textField.text, forKey: boundProperty)
        valueChanged?(self)
        return false
    }
}

