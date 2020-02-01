//
//  IconsViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

protocol ColorsViewControllerDelegate {
    func colorSelected(_ colorName: String)
}

class ColorsViewController: UITableViewController {

    private var dataSource = UIColor.stampsPalette().keys.sorted()
    
    var selectedColor = ""
    var delegate: ColorsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Color"
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 52.0
        tableView.separatorInset = UIEdgeInsets.zero
    }
}

// MARK: - UITableViewDataSource

extension ColorsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell", for: indexPath)
        
        let cellColorValue = UIColor.colorByName(dataSource[indexPath.row])
        
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.backgroundColor = UIColor(hex: cellColorValue)
        cell.accessoryType = cellColorValue == selectedColor ? .checkmark : .none
        cell.tintColor = .darkGray
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.colorSelected(dataSource[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

