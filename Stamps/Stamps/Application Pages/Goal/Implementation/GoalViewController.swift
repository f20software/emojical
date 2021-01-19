//
//  GoalViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

// In order to dymanically pass references to Goal properties to DynamicTables
// and being able to update them - we need to wrap `struct Goal` to a class object
// using only properties that we are actually going to expose for editing
class GoalRef : NSObject {
    @objc var name: String
    @objc var direction: Int
    @objc var period: Int
    @objc var limit: Int

    init(from: Goal) {
        name = from.name
        direction = from.direction.rawValue
        period = from.period.rawValue
        limit = from.limit
    }
    
    func update(to: inout Goal) {
        to.name = name
        to.period = Period(rawValue: period) ?? .week
        to.direction = Direction(rawValue: direction) ?? .positive
        to.limit = limit
    }
}


class GoalViewController: DTTableViewController {
    
    let segueCommit = "commitGoal"
    let segueSelectStamps = "selectStamps"
    
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    @IBOutlet var editBarButton: UIBarButtonItem!
    
    enum Presentation {
        // Modal presentation: edition ends with the "Commit" segue.
        case modal
        // Push presentation: edition ends when user hits the back button.
        case push
    }
    
    // Reference to Goal object
    var goal: Goal! {
        didSet {
            goalRef = GoalRef(from: goal)
        }
    }

    // Goal class reference - only used to be properly pass references to the object
    // to DynamicTables
    var goalRef: GoalRef?

    var currentProgress: Int?
    var presentationMode: Presentation! { didSet { configureView() } }
    var editMode: Bool!
    
    var repository: DataRepository {
        return Storage.shared.repository
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        createTableModel()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        editMode = editing
        // Update navigation title and re-create table view model
        configureBarButtons()
        createTableModel()
        
        guard animated == true else { return }

        // This is to properly animate table view transition from view mode to edit mode
        // in view mode we have just 1 section, in edit mode could have 2 (when delete button is shown)
        tableView.beginUpdates()
        tableView.reloadSections([0], with: .fade)
        if editMode {
            tableView.insertSections([1], with: .fade)
        }
        else {
            tableView.deleteSections([1], with: .fade)
        }
        tableView.endUpdates()
    }
    
    fileprivate func configureBarButtons() {
        title = goal.name
        if editMode {
            navigationItem.leftBarButtonItem = cancelBarButton
            navigationItem.setRightBarButtonItems([doneBarButton], animated: false)
        }
        else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.setRightBarButtonItems([editBarButton], animated: false)
        }
    }
    
    fileprivate func configureView() {
        guard isViewLoaded else { return }
        setEditing((presentationMode == .modal), animated: false)
    }
    
    fileprivate func createTableModel() {
        guard let goalRef = goalRef else { return }
        model.clear()
        let stickers = repository.stampLabelsFor(goal)

        if editMode {
            let mainSection = model.add(DTTableViewSection())

            let nameCell = DTTextFieldCell(text: "Name", boundObject: goalRef, boundProperty: "name")
            nameCell.valueChanged = { (_cell) -> Void in
                // Update form title with new value
                self.title = self.goal.name
            }
            nameCell.autocapitalizationType = .words

            let directionCell = DTSegmentedControlCell(text: "Direction", boundObject: goalRef, boundProperty: "direction", items: ["Positive", "Negative"])

            let limitCell = DTNumericTextFieldCell(text: "Goal", boundObject: goalRef, boundProperty: "limit")

            let periodCell = DTSegmentedControlCell(text: "Period", boundObject: goalRef, boundProperty: "period", items: ["Week", "Month"])

            let stickersCell = DTLabelCell(text: "Stickers", value: stickers.joined(separator: ", "))
            stickersCell.disclosureIndicator = true
            stickersCell.didSelect = { (_, _) -> Void in
                self.goalRef?.update(to: &self.goal)
                self.performSegue(withIdentifier: self.segueSelectStamps, sender: self)
            }
            
            mainSection.add(contentOf: [nameCell, directionCell, limitCell, periodCell, stickersCell])
            
            // Delete option is visible only when we're in the edit mode from editing existing entry and
            // not creating new one
            if presentationMode == .push {
                let deleteSection = model.add(DTTableViewSection(headerTitle: nil, footerTitle: "If you update or delete the goal, all previously earned awards would remain unchanged."))
                let deleteCell = deleteSection.add(DTButtonCell(text: "Delete Goal"))
                deleteCell.didSelect = { (_, _) -> Void in
                    self.confirmGoalDelete()
                }
            }
        }
        else {
            let mainSection = model.add(DTTableViewSection(headerTitle: nil))
            mainSection.add(contentOf: [
                DTTextViewCell(text: "\(goal.details).\n\nStickers: \(stickers.joined(separator: ", "))"),
                DTTextViewCell(text: goal.statsDescription)
            ])
            
            if currentProgress != nil {
                mainSection.add(
                    DTTextViewCell(text: goal.descriptionForCurrentProgress(currentProgress!)))
            }
        }
    }
}

// MARK: - Updating list of stamps from SelectStampsViewController
extension GoalViewController: SelectStampsViewControllerDelegate {

    func stampSelectionUpdated(_ selection: [Int64]) {
        goal.stamps = selection
        createTableModel()
        tableView.reloadData()
    }
}

// MARK: - Navigation
extension GoalViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueCommit {
            saveChanges()
        }
        else if segue.identifier == segueSelectStamps {
            if let stampsVC = (segue.destination as? SelectStampsViewController) {
                stampsVC.dataSource = repository.allStamps()
                stampsVC.selectedStamps = goal.stamps
                stampsVC.delegate = self
            }
        }
    }
}

// MARK: - Form
extension GoalViewController: UITextFieldDelegate {
    
    @IBAction func editTapped(_ sender: Any) {
        setEditing(true, animated: true)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        if presentationMode == .push {
            // Reload goal from the datasource and going back to view mode
            goalRef = GoalRef(from: goal)
            setEditing(false, animated: true)
        }
        else {
            dismiss(animated: true)
        }
    }

    @IBAction func doneTapped(_ sender: Any) {
        saveChanges()
        if presentationMode == .push {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    func deleteAndDismiss() {
        goal.deleted = true
        saveChanges()
        navigationController?.popViewController(animated: true)
    }
    
    func confirmGoalDelete() {
        if goal.count > 0 {
            let confirm = UIAlertController(title: "\(goal.statsDescription) Are you sure you want to delete it?", message: nil, preferredStyle: .actionSheet)
            confirm.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                self.deleteAndDismiss()
            }))
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                confirm.dismiss(animated: true, completion: nil)
            }))
            present(confirm, animated: true, completion: nil)
        }
        else {
            deleteAndDismiss()
        }
    }

    private func saveChanges() {
        guard let goalRef = goalRef else { return }
        goalRef.update(to: &goal)

        try! repository.save(goal: goal)
    }
}
