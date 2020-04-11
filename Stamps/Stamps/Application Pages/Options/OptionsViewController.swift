//
//  OptionsViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import MessageUI

class OptionsViewController: UITableViewController {

    @IBOutlet weak var exportCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell === exportCell {
            exportTapped(self)
        }
    }
    
    @IBAction func exportTapped(_ sender: Any) {
        let db = DataSource.shared
        
        let backupFileName = db.deviceBackupFileName
        if db.backupDatabase(to: backupFileName) {
            sendEmail(attachment: backupFileName)
        }
    }
    
    
    
    func sendEmail(attachment: URL) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            do {
                let data = try Data(contentsOf: attachment)
                mail.addAttachmentData(data, mimeType: "application/json", fileName: "backup.json")
            }
            catch {}
            
            mail.setMessageBody("Here is backup of your data", isHTML: false)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
}

extension OptionsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

