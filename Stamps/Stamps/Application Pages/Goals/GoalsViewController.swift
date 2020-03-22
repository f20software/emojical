//
//  GoalsViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import GRDB

class GoalsViewController: UITableViewController {

    private var goals: [Goal] = []
    private var goalsObserver: TransactionObserver?

    override func viewDidLoad() {
        super.viewDidLoad()
        goals = DataSource.shared.allGoals()
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTableView()
    }

    private func configureTableView() {
        // Track changes in the list of players
        let request = Goal.orderedByPeriodName()
        let observation = ValueObservation.tracking { db in
            try request.fetchAll(db)
        }
        goalsObserver = observation.start(
            in: DataSource.shared.dbQueue,
            onError: { error in
                fatalError("Unexpected error: \(error)")
        },
            onChange: { [weak self] goals in
                guard let self = self else { return }
                
                // Compute difference between current and new list of players
                let difference = goals
                    .difference(from: self.goals)
                    .inferringMoves()
                
                // Apply those changes to the table view
                self.tableView.performBatchUpdates({
                    self.goals = goals
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

extension GoalsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGoal" {
            let goal = goals[tableView.indexPathForSelectedRow!.row]
            // DataSource.shared.updateStatsForGoal(&goal)
            let controller = segue.destination as! GoalViewController
            controller.title = goal.name
            controller.goal = goal
            controller.currentProgress = AwardManager.shared.currentProgressFor(goal)
            controller.presentation = .push
        }
        else if segue.identifier == "newGoal" {
            setEditing(false, animated: true)
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.viewControllers.first as! GoalViewController
            controller.title = "New Goal"
            controller.goal = Goal(id: nil, name: "New Goal", period: .week, direction: .positive, limit: 5, stamps: "", deleted: false)
            controller.presentation = .modal
        }
    }
    
    @IBAction func cancelGoalEdition(_ segue: UIStoryboardSegue) {
        // Stamp creation cancelled
    }
    
    @IBAction func commitGoalEdition(_ segue: UIStoryboardSegue) {
        // Stamp creation committed
    }
}


// MARK: - UITableViewDataSource

extension GoalsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell", for: indexPath) as! GoalCell
        let goal = goals[indexPath.row]
        cell.configureWith(goal, currentProgress: AwardManager.shared.currentProgressFor(goal))
        return cell
    }
}

