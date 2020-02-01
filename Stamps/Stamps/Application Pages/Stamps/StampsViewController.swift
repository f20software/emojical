//
//  StampsViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import GRDB

class StampsViewController: UITableViewController {

    private var stamps: [Stamp] = []
    private var stampsObserver: TransactionObserver?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTableView()
    }

    private func configureTableView() {
        // Track changes in the list of players
        let request = Stamp.orderedByName()
        let observation = ValueObservation.tracking { db in
            try request.fetchAll(db)
        }
        stampsObserver = observation.start(
            in: DataSource.shared.dbQueue,
            onError: { error in
                fatalError("Unexpected error: \(error)")
        },
            onChange: { [weak self] stamps in
                guard let self = self else { return }
                
                // Compute difference between current and new list of players
                let difference = stamps
                    .difference(from: self.stamps)
                    .inferringMoves()
                
                // Apply those changes to the table view
                self.tableView.performBatchUpdates({
                    self.stamps = stamps
                    for change in difference {
                        switch change {
                        case let .remove(offset, _, associatedWith):
                            if let associatedWith = associatedWith {
                                self.tableView.moveRow(
                                    at: IndexPath(row: offset, section: 0),
                                    to: IndexPath(row: associatedWith, section: 0))
                            } else {
                                self.tableView.deleteRows(
                                    at: [IndexPath(row: offset, section: 0)],
                                    with: .fade)
                            }
                        case let .insert(offset, _, associatedWith):
                            if associatedWith == nil {
                                self.tableView.insertRows(
                                    at: [IndexPath(row: offset, section: 0)],
                                    with: .fade)
                            }
                        }
                    }
                }, completion: nil)
        })
    }

}

// MARK: - Navigation

extension StampsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let stamp = stamps[tableView.indexPathForSelectedRow!.row]
            let controller = segue.destination as! StampEditViewController
            controller.title = stamp.name
            controller.stamp = stamp
            controller.presentation = .push
        }
        else if segue.identifier == "new" {
            setEditing(false, animated: true)
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.viewControllers.first as! StampEditViewController
            controller.title = "New Stamp"
            controller.stamp = Stamp(id: nil, name: "", label: "star", color: UIColor.colorByName("Gold"), favorite: false, deleted: false)
            controller.presentation = .modal
        }
    }
    
    @IBAction func cancelStampEdition(_ segue: UIStoryboardSegue) {
        // Stamp creation cancelled
    }
    
    @IBAction func commitStampEdition(_ segue: UIStoryboardSegue) {
        // Stamp creation committed
    }
}


// MARK: - UITableViewDataSource

extension StampsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stamps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stampCell", for: indexPath) as! StampCell
        configure(cell, at: indexPath)
        return cell
    }
        
    private func configure(_ cell: StampCell, at indexPath: IndexPath) {
        let stamp = stamps[indexPath.row]
        
        cell.label.attributedText = NSAttributedString(string: stamp.label, attributes: [
            NSAttributedString.Key.baselineOffset: -1.5,
            NSAttributedString.Key.font: UIFont(name: "SS Symbolicons", size: 28.0)!,
            NSAttributedString.Key.foregroundColor: UIColor(hex: stamp.color)
        ])
        cell.name.text = stamp.name.isEmpty ? "-" : stamp.name
        cell.label.layer.borderColor = UIColor(hex: stamp.color).cgColor
    }
}
