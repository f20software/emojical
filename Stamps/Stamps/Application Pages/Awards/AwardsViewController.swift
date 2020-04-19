//
//  AwardsViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import GRDB

class AwardsViewController: UITableViewController {

    private var awards = [[Award]]()
    private var awardsObserver: TransactionObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awards = DataSource.shared.awardsGroupedByMonth(DataSource.shared.recentAwards())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTableView()
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: .newAwardsSeen, object: nil)
        }
    }

    private func configureTableView() {
        // Track changes in the list of players
        let request = Award.orderedByDateDesc()
        let observation = ValueObservation.tracking { db in
            try request.fetchAll(db)
        }
        awardsObserver = observation.start(
            in: DataSource.shared.dbQueue,
            onError: { error in
                fatalError("Unexpected error: \(error)")
        },
            onChange: { [weak self] awards in
                guard let self = self else { return }
                
                // Compute difference between current and new list of players
                
//                let difference = awards
//                    .difference(from: self.awards)
//                    .inferringMoves()
                
                self.awards = DataSource.shared.awardsGroupedByMonth(awards)
                self.tableView.reloadData()
                
                // Apply those changes to the table view
//                self.tableView.performBatchUpdates({
//                    self.awards = awards
//                    for change in difference {
//                        switch change {
//                        case let .remove(offset, _, associatedWith):
//                            if let associatedWith = associatedWith {
//                                self.tableView.moveRow(
//                                    at: IndexPath(row: offset, section: 0),
//                                    to: IndexPath(row: associatedWith, section: 0))
//                            } else {
//                                self.tableView.deleteRows(
//                                    at: [IndexPath(row: offset, section: 0)],
//                                    with: .fade)
//                            }
//                        case let .insert(offset, _, associatedWith):
//                            if associatedWith == nil {
//                                self.tableView.insertRows(
//                                    at: [IndexPath(row: offset, section: 0)],
//                                    with: .fade)
//                            }
//                        }
//                    }
//                }, completion: nil)
        })
    }
}

// MARK: - UITableViewDataSource

extension AwardsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return awards[section].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return awards.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Date(yyyyMmDd: awards[section][0].date)
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "awardCell", for: indexPath) as! AwardCell
        let award = awards[indexPath.section][indexPath.row]
        let goal = DataSource.shared.goalById(award.goalId)!
        cell.configureWith(award, goal: goal)
        return cell
    }
}
