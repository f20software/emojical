//
//  DTTableViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

protocol DTTableSelectionViewControllerDelegate {

    func valueSelected(viewController: UIViewController, value: String)
}


class DTTableSelectionViewController : UITableViewController {
    
    var items: [String] = []
    var currentValue: String?
    
    var delegate: DTTableSelectionViewControllerDelegate?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "selectionItem")
        let idx = indexPath.row

        // QuadPoint specific style
        cell.backgroundColor = DTStyle.themeColor(.backgroundColor)
        cell.textLabel?.textColor = DTStyle.themeColor(.textColor)
        cell.textLabel?.text = items[idx]
        if currentValue == items[idx] {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.valueSelected(viewController: self, value: items[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
