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
class DTLinkedSwitchCell: DTSwitchCell {
    
    // are linked cell shown right now?
    var linkedCellsShown: Bool = false
    
    // Set this property to true if you need linkedCells to be shown when Switch is ON, and to false otherwise.
    var showLinkedSwitchValue: Bool = true

    // Array of QPTableCell objects that have to be shown/hidden based on the value of Switch
    var linkedCells: [DTTableCell]?

    override func loadValue() {
        super.loadValue()
        guard let switchControl = switchControl else { return }

        switchControl.isOn = boundObject.value(forKey: boundProperty) as? Bool ?? false
        
        guard let linkedCells = linkedCells else { return }
        guard let ownerSection = ownerSection else { return }
        guard var row = myRow else { return }

        var needReload: Bool = false
        
        // Make sure the current state of ownerTableViewModel reflects the initial switchControl state
        if (switchControl.isOn == showLinkedSwitchValue)
        {
            row = row + 1
            for cell in linkedCells {
                if ownerSection.index(of: cell) == nil {
                    ownerSection.insert(cell, at: row)
                    row += 1
                    needReload = true
                }
            }
            
            if needReload {
                ownerTableViewModel?.tableView?.reloadData()
            }
            linkedCellsShown = true;
        }
        else
        {
            for cell in linkedCells {
                if let i = ownerSection.index(of: cell) {
                    ownerSection.removeCell(at: i)
                    needReload = true
                }
            }
            
            if needReload {
                ownerTableViewModel?.tableView?.reloadData()
            }
            linkedCellsShown = false;
        }
    }

    // We need to now where current QPSwitchCell sits in the section to now where
    // to insert linked cells
    var myRow: Int? {
        return self.ownerSection?.index(of: self)
    }

    // indexPath for this QPSwitchCell. We need to know it, when we're reloading this cell
    var indexPathForCurrentCell: IndexPath? {
        guard let ownerSection = ownerSection else { return nil }
        let row = myRow
        let section = ownerTableViewModel?.index(of: ownerSection)
        
        guard row != nil, section != nil else { return nil }
        return IndexPath(row: row!, section: section!)
    }
    
    // Array of IndexPath for current cell + all linked cell below it
    var indexPathsForLinkedCells: [IndexPath]? {
        guard let linkedCells = linkedCells else { return nil }
        guard var row = myRow else { return nil }
        guard let section = ownerTableViewModel?.index(of: ownerSection) else { return nil }

        var result = [IndexPath]()
        row = row + 1
        
        for _ in linkedCells {
            let ip = IndexPath(row: row, section: section)
            row += 1
            result.append(ip)
        }
        
        return result
    }


    func showLinkedCells() {
        // Double check that we're in correct state
        if linkedCellsShown == true {
            return
        }
        guard let linkedCells = linkedCells else { return }
        guard let ownerSection = ownerSection else { return }
        guard var row = myRow else { return }
        
        row = row + 1
        for cell in linkedCells {
            ownerSection.insert(cell, at: row)
            row += 1
        }
        
        linkedCellsShown = true;
        
        // Sometime appeance of the cell differ when cell is in the middle of section or
        // the very last one in the section. When we hide/show linked cells, this cell position might change and
        // it can become last cell in section. To ensure proper visual representation of current switch
        // cell we need to call reloadRowsAtIndexPaths method. But we can do this only after animation
        // for showing/hiding linked cells is complete. That's why we're wrapping insertRowsAtIndexPaths into CATransaction
        
        // If we for some reason don't have refernce to tableView - animating anything is moot point
        guard let tableView = ownerTableViewModel?.tableView else { return }
        
        CATransaction.begin()

        tableView.beginUpdates()
        CATransaction.setCompletionBlock { () -> Void in
            tableView.reloadRows(at: [self.indexPathForCurrentCell!], with: .none)
        }
        // add linkedCell to the table view with animation
        tableView.insertRows(at: self.indexPathsForLinkedCells!, with: .fade)
        tableView.endUpdates()

        CATransaction.commit()
    }
    
    func hideLinkedCells() {
        // Double check that we're in correct state
        if linkedCellsShown == false {
            return
        }
        guard let linkedCells = linkedCells else { return }
        guard let ownerSection = ownerSection else { return }
        guard var row = myRow else { return }

        row = row + 1
        for _ in linkedCells {
            ownerSection.removeCell(at: row)
        }
        
        linkedCellsShown = false;
        
        // See comments above in showLinkedCells method related to using CATransaction

        // If we for some reason don't have refernce to tableView - animating anything is moot point
        guard let tableView = ownerTableViewModel?.tableView else { return }

        CATransaction.begin()

        tableView.beginUpdates()
        CATransaction.setCompletionBlock { () -> Void in
            tableView.reloadRows(at: [self.indexPathForCurrentCell!], with: .none)
        }
        // add linkedCell to the table view with animation
        tableView.deleteRows(at: indexPathsForLinkedCells!, with: .fade)
        tableView.endUpdates()

        CATransaction.commit()
    }
    
    override func createCell(with identifier: String) -> UITableViewCell {
        let cell = super.createCell(with: identifier)
        return cell
    }
    
    @objc override func switchValueChanged(sender: UISwitch) {
        // Update bound object and call cell handler if set
        boundObject.setValue(NSNumber(booleanLiteral: sender.isOn), forKey: boundProperty)
        valueChanged?(self)
        
        guard linkedCells != nil else {
            return
        }
            
        // Update linkedCell visibility based on the switchControl on value
        if(sender.isOn == showLinkedSwitchValue)
        {
            showLinkedCells()
        }
        else
        {
            hideLinkedCells()
        }
    }
}

