//
//  SelectStampsViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

protocol SelectStampsViewControllerDelegate {
    func stampSelectionUpdated(_ selection: [Int64])
}

class SelectStampsViewController: UITableViewController {

    var dataSource = [Stamp]()
    var selectedStamps = [Int64]()
    
    var delegate: SelectStampsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Stickers"
    }
}

// MARK: - UITableViewDataSource

extension SelectStampsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectStampCell", for: indexPath) as! SelectStampCell
        
        let stamp = dataSource[indexPath.row]
        cell.name!.text = stamp.name.isEmpty ? " " : stamp.name
        cell.label!.color = stamp.color
        cell.label!.text = stamp.label
        
        if selectedStamps.contains(stamp.id!) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stamp = dataSource[indexPath.row]
        if selectedStamps.contains(stamp.id!) {
            selectedStamps.removeAll { $0 == stamp.id! }
        }
        else {
            selectedStamps.append(stamp.id!)
        }
        delegate?.stampSelectionUpdated(selectedStamps)
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

