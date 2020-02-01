import UIKit

class StampEditViewController: UITableViewController {
    
    enum Presentation {
        // Modal presentation: edition ends with the "Commit" segue.
        case modal
        
        // Push presentation: edition ends when user hits the back button.
        case push
    }
    
    var stamp: Stamp! { didSet { configureView() } }
    var presentation: Presentation! { didSet { configureView() } }

    @IBOutlet fileprivate weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet fileprivate weak var commitBarButtonItem: UIBarButtonItem!
    @IBOutlet fileprivate weak var nameCell: UITableViewCell!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var labelCell: UITableViewCell!
    @IBOutlet fileprivate weak var labelLabel: UILabel!
    @IBOutlet fileprivate weak var colorCell: UITableViewCell!
    @IBOutlet fileprivate weak var colorLabel: UILabel!
    @IBOutlet weak var favoriteCell: UITableViewCell!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        stamp.name = nameTextField.text ?? ""
        title = stamp.name
    }

    @IBAction func favoriteChanged(_ sender: Any) {
        stamp.favorite = favoriteSwitch.isOn
    }
    
    fileprivate func configureView() {
        guard isViewLoaded else { return }
        
        labelLabel.attributedText = NSAttributedString(string: stamp.label, attributes: [
            NSAttributedString.Key.baselineOffset: -1.5,
            NSAttributedString.Key.font: UIFont(name: "SS Symbolicons", size: 28.0)!,
            NSAttributedString.Key.foregroundColor: UIColor(hex: stamp.color)
        ])
        labelLabel.layer.cornerRadius = 23.0
        labelLabel.layer.borderWidth = 2.0
        labelLabel.clipsToBounds = true
        labelLabel.layer.borderColor = UIColor(hex: stamp.color).cgColor

        nameTextField.text = stamp.name
        
        colorLabel.text = UIColor.nameByColor(stamp.color)
        colorCell.backgroundColor = UIColor(hex: stamp.color)
        
        favoriteSwitch.tintColor = UIColor(hex: stamp.color)
        favoriteSwitch.isOn = stamp.favorite

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


// MARK: - Navigation

extension StampEditViewController {
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Force keyboard to dismiss early
        view.endEditing(true)
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commit" {
            saveChanges()
        }
        else if segue.identifier == "selectStamp" {
            if let iconsVC = (segue.destination as? IconsViewController) {
                iconsVC.selectedStamp = stamp.label
                iconsVC.delegate = self
            }
        }
        else if segue.identifier == "selectColor" {
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

// MARK: - Updating stamp label from IconsViewController
extension StampEditViewController: IconsViewControllerDelegate {
    
    func iconSelected(_ icon: String) {
        stamp.label = icon
    }
}

// MARK: - Updating stamp color from ColorViewController
extension StampEditViewController: ColorsViewControllerDelegate {
    
    func colorSelected(_ colorName: String) {
        stamp.color = UIColor.colorByName(colorName)
    }
}


// MARK: - Form

extension StampEditViewController: UITextFieldDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // nameTextField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if cell === nameCell {
            nameTextField.becomeFirstResponder()
        } else if cell === labelCell {
            // scoreTextField.becomeFirstResponder()
        } else if cell === colorCell {
            //
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            // scoreTextField.becomeFirstResponder()
        }
        return false
    }
    
    private func saveChanges() {
        guard var stamp = self.stamp else {
            return
        }
        
        stamp.name = nameTextField.text ?? ""
        self.stamp = stamp
        
        try! DataSource.shared.dbQueue.inDatabase { db in
            try stamp.save(db)
        }
    }
}
