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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func exportTapped(_ sender: Any) {
        
        let fileName = DataSource.shared.backupDatabase()
        sendEmail(attachment: fileName)
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

