//
//  GoalViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalViewController: UITableViewController {
    
    let segueCommit = "commitGoal"
    let segueSelectStamps = "selectStamps"
    
    enum Presentation {
        // Modal presentation: edition ends with the "Commit" segue.
        case modal
        
        // Push presentation: edition ends when user hits the back button.
        case push
    }
    
    var goal: Goal!
    var presentation: Presentation! { didSet { configureView() } }

    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var commitBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var limitCell: UITableViewCell!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var limitTextField: UITextField!
    @IBOutlet weak var direction: UISegmentedControl!
    @IBOutlet weak var period: UISegmentedControl!
    @IBOutlet weak var stampsLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGoal()
    }

    fileprivate func configureView() {
        guard isViewLoaded else { return }
        
        tableView.tableFooterView = UIView()
        
        switch presentation! {
        case .modal:
            navigationItem.leftBarButtonItem = cancelBarButtonItem
            navigationItem.rightBarButtonItem = commitBarButtonItem
        case .push:
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }
    }
}

// MARK: - Updating list of stamps from SelectStampsViewController
extension GoalViewController: SelectStampsViewControllerDelegate {

    func stampSelectionUpdated(_ selection: [Int64]) {
        goal.stampIds = selection
    }
}

// MARK: - Navigation
extension GoalViewController {
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Force keyboard to dismiss early
        view.endEditing(true)
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueCommit {
            saveChanges()
        }
        else if segue.identifier == segueSelectStamps {
            if let stampsVC = (segue.destination as? SelectStampsViewController) {
                stampsVC.dataSource = DataSource.shared.allStamps()
                stampsVC.selectedStamps = goal.stampIds
                stampsVC.delegate = self
            }
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        switch presentation! {
        case .modal:
            break
        case .push:
            if parent == nil {
                // Self is popping from its navigation controller
                saveChanges()
            }
        }
    }
}

// MARK: - Form
extension GoalViewController: UITextFieldDelegate {
    
    @IBAction func formValueChanged(_ sender: Any) {
        updateGoal()
        
        // There are few UI elements we want to update in real-time as user changes their values
        // We don't want to call loadGoal() to refresh everything, since it will dismiss the keyboard
        // instead we manually update title, description label and footer text
        DispatchQueue.main.async {
            self.title = self.goal.name
            // Little hacky - we want to update first sectino footer, but don't want to reload whole section because of it
            self.limitLabel.text = self.goal.limitName
            if let footer = self.tableView.footerView(forSection: 0) {
                footer.textLabel?.text = self.goal.details
                footer.setNeedsLayout() // in case new text is longer then the old one
            }
        }
    }

    // Updated stored property with values from UI
    func updateGoal() {
        goal.name = nameTextField.text ?? ""
        goal.limit = Int(limitTextField.text ?? "") ?? 0
        goal.direction = Goal.Direction(rawValue: direction.selectedSegmentIndex) ?? .positive
        goal.period = Goal.Period(rawValue: period.selectedSegmentIndex) ?? .week
    }
    
    // Load values from goal property to UI
    func loadGoal() {
        nameTextField.text = goal.name
        limitTextField.text = "\(goal.limit)"
        limitLabel.text = goal.limitName
        direction.selectedSegmentIndex = goal.direction.rawValue
        period.selectedSegmentIndex = goal.period.rawValue

        // Get all labels from Ids that are part of Goal object
        let stampIds = goal.stampIds
        var stampLabels = [String]()
        for i in stampIds {
            if let label = DataSource.shared.stampById(i)?.label {
                stampLabels.append(label)
            }
        }
        
        stampsLabel.attributedText = NSAttributedString(string: stampLabels.joined(separator: ", "), attributes: [
            NSAttributedString.Key.baselineOffset: -1.5,
            NSAttributedString.Key.font: UIFont(name: "SS Symbolicons", size: 20.0)!
        ])
        statsLabel.text = goal.statsDescription
    }
    
    // Auto-selecting text fields when cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)

        if cell === nameCell {
            nameTextField.becomeFirstResponder()
        } else if cell === limitCell {
            limitTextField.becomeFirstResponder()
        } else {
            nameTextField.resignFirstResponder()
            limitTextField.resignFirstResponder()
        }
    }
    
    // We want to be able to dynamically update footer for the first section with
    // human readable goal description
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return goal.details
        }
        else if section == 1 {
            return "If you update the goal, all previously scored awards would remain untouched"
        }
        
        return nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            limitTextField.becomeFirstResponder()
        }
        return false
    }
    
    private func saveChanges() {
        updateGoal()
        try! DataSource.shared.dbQueue.inDatabase { db in
            try goal.save(db)
        }
    }
}
