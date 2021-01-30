//
//  OptionsPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/29/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class OptionsPresenter: NSObject, OptionsPresenterProtocol {

    // MARK: - DI

    private weak var view: OptionsView?
    private weak var settings: LocalSettings!
    private weak var coordinator: OptionsCoordinatorProtocol?
    
    // MARK: - State

    // MARK: - Lifecycle

    init(
        view: OptionsView,
        settings: LocalSettings,
        coordinator: OptionsCoordinatorProtocol
    ) {
        self.view = view
        self.settings = settings
        self.coordinator = coordinator
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
                header: "Notifications",
                footer: "We will remind you every day around 9pm to fill your entry for the day.",
                cells: [
                    .switch("Remind Me", settings.reminderEnabled, { [weak self] newValue in
                        self?.settings.reminderEnabled = newValue
                    })
                ]
            ),
            OptionsSection(
                header: nil,
                footer: nil,
                cells: [
                    .button("Backup Data...", { [weak self] in
                        self?.emailDataBackup()
                    }),
                    .button("Send Feedback...", { [weak self] in
                        self?.sendFeedback()
                    }),
                ]
            ),
            OptionsSection(
                header: nil,
                footer: nil,
                cells: [
                    .navigate("Development Options", { [weak self] in
                        self?.coordinator?.developerOptions()
                    })
                ]
            )
        ]
        
        view?.loadData(data)
    }

    private func sendFeedback() {
        sendFeedbackEmail(
            to: "feedback@emojical.app",
            subject: "Emojical Feedback"
        )
    }

    private func emailDataBackup() {
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

extension OptionsPresenter: MFMailComposeViewControllerDelegate {
    
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
