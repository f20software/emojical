//
//  GoalViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalViewController: UITableViewController {
    
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
    @IBOutlet weak var limitTextField: UITextField!

    @IBOutlet weak var direction: UISegmentedControl!
    @IBOutlet weak var period: UISegmentedControl!
    
    @IBOutlet weak var stampsCell: UITableViewCell!
    @IBOutlet weak var stampsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    fileprivate func configureView() {
        guard isViewLoaded else { return }
        
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        
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
        goal.stamps = selection.map({ String($0) }).joined(separator: ",")
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
        if segue.identifier == "commitGoal" {
            saveChanges()
        }
        else if segue.identifier == "selectStamps" {
            if let stampsVC = (segue.destination as? SelectStampsViewController) {
                stampsVC.dataSource = DataSource.shared.allStamps()
                stampsVC.selectedStamps = goal.stampIds ?? [Int64]()
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
        loadGoal()
        
        DispatchQueue.main.async {
            self.title = self.goal.name
            // self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }

    func updateGoal() {
        goal.name = nameTextField.text ?? ""
        goal.limit = Int(limitTextField.text!) ?? 0
        goal.direction = direction.selectedSegmentIndex == 0 ? .positive : .negative
        goal.period = period.selectedSegmentIndex == 0 ? .week : .month
    }
    
    func loadGoal() {
        nameTextField.text = goal.name
        limitTextField.text = "\(goal.limit)"
        direction.selectedSegmentIndex = (goal.direction == .positive ? 0 : 1)
        period.selectedSegmentIndex = (goal.period == .week ? 0 : 1)

        // Get all labels from Ids that are part of Goal object
        let stampIds = goal.stampIds
        var stampLabels = [String]()
        if stampIds != nil {
            for i in stampIds! {
                if let label = DataSource.shared.stampById(i)?.label {
                    stampLabels.append(label)
                }
            }
        }
        
        stampsLabel.attributedText = NSAttributedString(string: stampLabels.joined(separator: ", "), attributes: [
            NSAttributedString.Key.baselineOffset: -1.5,
            NSAttributedString.Key.font: UIFont(name: "SS Symbolicons", size: 20.0)!
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGoal()
        // nameTextField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if cell === nameCell {
            nameTextField.becomeFirstResponder()
        } else if cell === limitCell {
            limitTextField.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return goal.details
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            // scoreTextField.becomeFirstResponder()
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
