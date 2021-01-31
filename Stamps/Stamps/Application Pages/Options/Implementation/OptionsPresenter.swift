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
    private weak var repository: DataRepository!
    private weak var coordinator: OptionsCoordinatorProtocol?
    
    // MARK: - State

    // MARK: - Lifecycle

    init(
        view: OptionsView,
        repository: DataRepository,
        settings: LocalSettings,
        coordinator: OptionsCoordinatorProtocol
    ) {
        self.view = view
        self.repository = repository
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
        let key = kCFBundleVersionKey as String
        let version = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "N/A"
        
        let data: [Section] = [
            Section(
                header: "Reminder",
                footer: "Remind every day around 9pm to fill your entry for that day if you haven't done so already.",
                cells: [
                    .switch("Daily Reminder", settings.reminderEnabled, { [weak self] newValue in
                        self?.settings.reminderEnabled = newValue
                        // Force notification manager to update reminder
                        NotificationCenter.default.post(name: .todayStickersUpdated, object: nil)
                    })
                ]
            ),
            Section(
                header: "Backup / Restore",
                footer: "Email yourself JSON file with all your data.",
                cells: [
                    .button("Export Your Data...", { [weak self] in
                        self?.emailDataBackup()
                    }),
                ]
            ),
            Section(
                header: nil,
                footer: "Emojical, \(version), © 2021",
                cells: [
                    .button("Feedback...", { [weak self] in
                        self?.sendFeedback()
                    }),
                    .navigate("Developer Options", { [weak self] in
                        self?.coordinator?.developerOptions()
                    }),
                ]
            ),
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
