//
//  DTTableViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class DTTableViewController : UITableViewController {
    
    var model = DTTableViewModel()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        model.tableView = self.tableView
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].visibleCellsCount
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModel = model.cellModel(at: indexPath)
        let identifier = "\(indexPath.section)-\(indexPath.row)"

        let cell = cellModel.createCell(with: identifier)
        cellModel.loadValue()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cellModel = model.cellModel(at: indexPath)
        cellModel.didSelectRow(at: indexPath, viewController: self)
    }
}
