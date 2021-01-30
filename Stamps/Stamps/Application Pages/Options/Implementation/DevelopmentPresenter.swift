//
//  DevelopmentPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class DevelopmentPresenter: NSObject, DevelopmentPresenterProtocol {

    // MARK: - DI

    private weak var view: DevelopmentView?
    private weak var settings: LocalSettings!
    
    // MARK: - State

    // MARK: - Lifecycle

    init(
        view: DevelopmentView,
        settings: LocalSettings
    ) {
        self.view = view
        self.settings = settings
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
    }
    
    private func loadViewData() {
        let data: [OptionsSection] = [
            OptionsSection(
                header: nil,
                footer: nil,
                cells: [
                    .text("Notifications", settings.reminderEnabled ? "On" : "Off"),
                    .text("Id", settings.todayNotificationId ?? "-"),
                ]
            ),
            OptionsSection(
                header: "Testing Notifications",
                footer: nil,
                cells: [
                    .button("Significant Time Change", {
                        NotificationCenter.default.post(
                            name: UIApplication.significantTimeChangeNotification, object: nil)
                    }),
                    .button("Navigate to Today", {
                        NotificationCenter.default.post(
                            name: .navigateToToday, object: nil)
                    }),
                    .button("Week Recap is Ready", {
                        NotificationCenter.default.post(
                            name: .weekClosed, object: nil)
                    }),
                ]
            ),
            OptionsSection(
                header: "Log File",
                footer: nil,
                cells: [
                    .button("Email Log File...", { [weak self] in
                        self?.emailLogFile()
                    }),
                ]
            ),
        ]
        
        view?.loadData(data)
    }

    private func emailLogFile() {
        let repository = Storage.shared.repository
        let backupFileName = repository.deviceBackupFileName
        
        if repository.backupDatabase(to: backupFileName) {
            sendBackupEmail(
                attachment: backupFileName,
                fileName: "emojical-backup-\(Date().databaseKey).json"
            )
        }
    }
}
    
// MARK: - MFMailComposeViewControllerDelegate

extension DevelopmentPresenter: MFMailComposeViewControllerDelegate {
    
    private var mailComposer: MFMailComposeViewController? {
        guard MFMailComposeViewController.canSendMail() else {
            return nil
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        return mail
    }
    
    private func sendBackupEmail(attachment: URL, fileName: String) {
        guard let mail = mailComposer else {
            return
        }

        do {
            let data = try Data(contentsOf: attachment)
            mail.addAttachmentData(data, mimeType: "application/json", fileName: fileName)
        }
        catch {}

        mail.setMessageBody("Here is backup of your data", isHTML: false)
        view?.viewController?.present(mail, animated: true)
    }

    private func sendFeedbackEmail(to: String, subject: String) {
        guard let mail = mailComposer else {
            return
        }

        mail.setSubject(subject)
        mail.setToRecipients([to])
        view?.viewController?.present(mail, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


    
    //private func confirmAddAction() {
//        let confirm = UIAlertController(title: "Create New...", message: nil, preferredStyle: .actionSheet)
//        confirm.addAction(UIAlertAction(title: "Sticker", style: .default, handler: { (_) in
//            self.coordinator?.newSticker()
//        }))
//        confirm.addAction(UIAlertAction(title: "Goal", style: .default, handler: { (_) in
//            self.coordinator?.newGoal()
//        }))
//        confirm.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
//            confirm.dismiss(animated: true, completion: nil)
//        }))
//        (view as! UIViewController).present(confirm, animated: true, completion: nil)
    //}
//}
