//
//  StampViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

// In order to dymanically pass references to Stamp properties to DynamicTables
// and being able to update them - we need to wrap `struct Stamp` to a class object
// using only properties that we are actually going to expose for editing
class StampRef : NSObject {
    @objc var name: String
    @objc var label: String
    @objc var color: String

    init(from: Stamp) {
        name = from.name
        label = from.label
        color = from.color
    }
    
    func update(to: inout Stamp) {
        to.name = name
        to.label = label
        to.color = color
    }
}

class StampViewController: DTTableViewController {
    
    let segueCommit = "commitStamp"
    let segueSelectColor = "selectColor"

    @IBOutlet var cancelBarButton: UIBarButtonItem!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var editBarButton: UIBarButtonItem!

    enum Presentation {
        // Modal presentation: edition ends with the "Commit" segue.
        case modal
        // Push presentation: edition ends when user hits the back button.
        case push
    }
    
    // Reference to Stamp object
    var stamp: Stamp! { didSet { stampRef = StampRef(from: stamp) }}
    // Stamp class reference - only used to be properly pass references to the object
    // to DynamicTables
    var stampRef: StampRef?
    
    var preview: StickerView?
    var previewTitle: UILabel?

    var presentationMode: Presentation! { didSet { configureView() } }
    var editMode: Bool!

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
        // in view mode we have just 2 sections, in edit mode could have 3 (when delete button is shown)
        // Preview section (0) remains unchanged across two modes
        tableView.beginUpdates()
        tableView.reloadSections([1], with: .fade)
        let goals = DataSource.shared.goalsUsedStamp(stamp.id!)
        if goals.count <= 0 {
            tableView.reloadSections([2], with: .fade)
        }
        else {
            if editMode {
                tableView.insertSections([2], with: .fade)
            }
            else {
                tableView.deleteSections([2], with: .fade)
            }
        }
        tableView.endUpdates()
    }

    fileprivate func loadStickerPreview() {
        guard let preview = preview,
            let previewTitle = previewTitle,
            let stampRef = stampRef else { return }

        previewTitle.text = stampRef.name
        preview.color = UIColor(hex: stampRef.color)
        preview.text = stampRef.label
        preview.setNeedsDisplay()
        previewTitle.setNeedsLayout()
    }
    
    fileprivate func configureBarButtons() {
        title = stamp.name
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
        guard let stampRef = stampRef else { return }
        model.clear()
        
        let previewSection = model.add(DTTableViewSection())
        let stickerCell = DTCustomCell(xibFile: "CustomStickerCell")
        stickerCell.cellCreated = { (_dtcell) -> Void in
            self.preview = _dtcell._cell?.contentView.subviews.first(where: { $0 is StickerView }) as? StickerView
            self.previewTitle = _dtcell._cell?.contentView.subviews.first(where: { $0 is UILabel }) as? UILabel
            self.loadStickerPreview()
        }
        previewSection.add(stickerCell)

        if editMode {
            let mainSection = model.add(DTTableViewSection())
            let nameCell = DTTextFieldCell(text: "Name", boundObject: stampRef, boundProperty: "name")
            nameCell.valueChanged = { (_cell) -> Void in
                self.title = self.stampRef?.name
                self.loadStickerPreview()
            }

            let labelCell = DTEmojiTextFieldCell(text: "Emoji", boundObject: stampRef, boundProperty: "label")
            labelCell.valueChanged = { (_cell) -> Void in
                self.loadStickerPreview()
            }

            // let colorCell = DTLabelCell(text: "Color", value: UIColor.nameByColor(stampRef.color))
            let colorCell = DTColorCell(text: nil, boundObject: stampRef, boundProperty: "color", colorValues: UIColor.colorPalette)
            colorCell.valueChanged = { (_cell) -> Void in
                self.loadStickerPreview()
            }
             
            mainSection.add(contentOf: [nameCell, labelCell, colorCell])
            
            // Delete option is visible only when we're in the edit mode from editing existing entry and
            // not creating new one
            if presentationMode == .push {
                let deleteSection = model.add(DTTableViewSection())
                let deleteCell = deleteSection.add(DTButtonCell(text: "Delete Sticker"))
                deleteCell.didSelect = { (_, _) -> Void in
                    self.confirmStampDelete()
                }
            }
        }
        else {
            let mainSection = model.add(DTTableViewSection())
            mainSection.add(
                DTTextViewCell(text: stamp.statsDescription))

            let goals = DataSource.shared.goalsUsedStamp(stamp.id!)
            if goals.count == 0 {
                let linkSection = model.add(DTTableViewSection())
                linkSection.add(
                    DTTextViewCell(text: "You haven't created a goal yet with this sticker."))

                let newGoalCell = DTButtonCell(text: "Create New Goal...")
                newGoalCell.textColor = DTStyle.themeColor(.tintColor)
                newGoalCell.didSelect = { (_, _) -> Void in
                    self.performSegue(withIdentifier: "newGoal", sender: send)
                }
                    
                linkSection.add(newGoalCell)
            }
            else if goals.count == 1 {
                mainSection.add(
                    DTTextViewCell(text: "Sticker is used in \'\(goals[0].name)\' goal."))
            }
            else {
                let text = goals.map({ "'\($0.name)'" }).sentence
                mainSection.add(
                    DTTextViewCell(text: "Sticker is used in \(text) goals."))
            }
                

        }
    }
}

// MARK: - Navigation
extension StampViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueCommit {
            saveChanges()
        }
        else if segue.identifier == "newGoal" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.viewControllers.first as! GoalViewController
            controller.title = "New Goal"
            controller.goal = Goal(id: nil, name: "New Goal", period: .week, direction: .positive, limit: 5, stamps: "\(stamp.id!)")
            controller.presentationMode = .modal
        }
    }

    @IBAction func commitGoalEdition(_ segue: UIStoryboardSegue) {
        // If goal was created - let's reload the table
        createTableModel()
        tableView.reloadData()
    }
}

// MARK: - Form
extension StampViewController {
    
    @IBAction func editTapped(_ sender: Any) {
        setEditing(true, animated: true)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        if presentationMode == .push {
            // Reload goal from the datasource and going back to view mode
            stampRef = StampRef(from: stamp)
            setEditing(false, animated: true)
            loadStickerPreview()
        }
        else {
            dismiss(animated: true)
        }
    }

    func deleteAndDismiss() {
        stamp.deleted = true
        saveChanges()
        navigationController?.popViewController(animated: true)
    }
    
    func confirmStampDelete() {
        if stamp.count > 0 {
            let confirm = UIAlertController(title: "\(stamp.statsDescription). Are you sure you want to delete it?", message: nil, preferredStyle: .actionSheet)
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
        guard let stampRef = stampRef else { return }
        stampRef.update(to: &stamp)
        
        try! DataSource.shared.dbQueue.inDatabase { db in
            try stamp.save(db)
        }
    }
}
