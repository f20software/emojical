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
    @IBOutlet weak var labelCell: UITableViewCell!
    @IBOutlet weak var labelTextField: EmojiTextField!
    @IBOutlet weak var colorBadge: UIView!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var stats: UILabel!
    
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
        
        colorBadge.layer.cornerRadius = 5.0
        colorBadge.layer.borderColor = UIColor.gray.cgColor
        colorBadge.layer.borderWidth = 1.0
        colorBadge.clipsToBounds = true
        
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


// MARK: - Form
extension StampViewController: UITextFieldDelegate {
    
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
        stamp.label = labelTextField.text ?? ""
        stamp.name = nameTextField.text ?? ""
        stamp.favorite = favoriteSwitch.isOn
    }
    
    func loadStamp() {
        nameTextField.text = stamp.name
        labelTextField.text = stamp.label
        colorBadge.backgroundColor = UIColor(hex: stamp.color)
        favoriteSwitch.isOn = stamp.favorite
        stats.text = stamp.statsDescription
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if cell === nameCell {
            nameTextField.becomeFirstResponder()
        } else if cell === labelCell {
            labelTextField.becomeFirstResponder()
        } else {
            nameTextField.resignFirstResponder()
            labelTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            nameTextField.resignFirstResponder()
        }
        return false
    }
    
    private func saveChanges() {
        updateStamp()
        try! DataSource.shared.dbQueue.inDatabase { db in
            try stamp.save(db)
        }
    }
}
