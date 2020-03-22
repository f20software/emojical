//
//  StampViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StampViewController: UITableViewController {
    
    let segueCommit = "commitStamp"
    let segueSelectColor = "selectColor"

    enum Presentation {
        // Modal presentation: edition ends with the "Commit" segue.
        case modal
        
        // Push presentation: edition ends when user hits the back button.
        case push
    }
    
    var stamp: Stamp!
    var presentation: Presentation! { didSet { configureView() } }
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var commitBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emojiCell: UITableViewCell!
    @IBOutlet weak var emojiTextField: EmojiTextField!
    @IBOutlet weak var colorBadge: StickerView!
    @IBOutlet weak var stats: UILabel!
    @IBOutlet weak var deleteCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStamp()
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

// MARK: - TableView handling

extension StampViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch presentation! {
        case .modal:
            return 1
        case .push:
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if cell === nameCell {
            nameTextField.becomeFirstResponder()
        } else if cell === emojiCell {
            emojiTextField.becomeFirstResponder()
        } else if cell == deleteCell {
            confirmStampDelete()
        } else {
            nameTextField.resignFirstResponder()
            emojiTextField.resignFirstResponder()
        }
    }
}


// MARK: - Navigation

extension StampViewController {
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Force keyboard to dismiss early
        view.endEditing(true)
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueCommit {
            saveChanges()
        }
        else if segue.identifier == segueSelectColor {
            if let colorsVC = (segue.destination as? ColorsViewController) {
                colorsVC.selectedColor = stamp.color
                colorsVC.delegate = self
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

// MARK: - Updating stamp color from ColorViewController
extension StampViewController: ColorsViewControllerDelegate {
    
    func colorSelected(_ colorName: String) {
        stamp.color = UIColor.colorByName(colorName)
    }
}

// MARK: - UITextFieldDelegate
extension StampViewController: UITextFieldDelegate {
    
    // Helping navigate from one text field to another
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            emojiTextField.becomeFirstResponder()
        }
        else if textField === emojiTextField {
            nameTextField.becomeFirstResponder()
        }
        return false
    }
    
    // Limit emoji text field to a single character
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === emojiTextField {
            textField.text = String(string.first ?? " ")
            updateStamp()
            DispatchQueue.main.async {
                self.colorBadge.text = self.stamp.label
            }
            return false
        }
        
        return true
    }
}

// MARK: - Form
extension StampViewController {
    
    @IBAction func formValueChanged(_ sender: Any) {
        updateStamp()
        
        // There are few UI elements we want to update in real-time as user changes their values
        // We don't want to call loadGoal() to refresh everything, since it will dismiss the keyboard
        // instead we manually update title, description label and footer text
        DispatchQueue.main.async {
            self.title = self.stamp.name
        }
    }

    func updateStamp() {
        stamp.label = emojiTextField.text ?? ""
        stamp.name = nameTextField.text ?? ""
    }
    
    func loadStamp() {
        nameTextField.text = stamp.name
        emojiTextField.text = stamp.label
        
        colorBadge.color = UIColor(hex: stamp.color)
        colorBadge.text = stamp.label
        
        stats.text = stamp.statsDescription
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
        updateStamp()
        try! DataSource.shared.dbQueue.inDatabase { db in
            try stamp.save(db)
        }
    }
}
