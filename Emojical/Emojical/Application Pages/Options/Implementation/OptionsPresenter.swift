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
    private weak var calender: CalendarHelper!
    private weak var notificationManager: NotificationManagerProtocol!
    
    // MARK: - State
    
    private var showDeveloperMenu = false

    // MARK: - Lifecycle

    init(
        view: OptionsView,
        repository: DataRepository,
        settings: LocalSettings,
        coordinator: OptionsCoordinatorProtocol,
        calendar: CalendarHelper,
        notificationManager: NotificationManagerProtocol
    ) {
        self.view = view
        self.repository = repository
        self.settings = settings
        self.coordinator = coordinator
        self.calender = calendar
        self.notificationManager = notificationManager
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
        view?.onSecretTap = { [weak self] in
            self?.showDeveloperMenu.toggle()
            self?.loadViewData()
        }
    }
    
    private func loadViewData() {
        let key = kCFBundleVersionKey as String
        let version = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "N/A"
        
        var data: [Section] = [
            Section(
                header: "reminder_title".localized,
                footer: "reminder_footer".localized,
                cells: [
                    .switch("reminder_option".localized, settings.reminderEnabled, { [weak self] newValue in
                        self?.updateReminder(to: newValue)
                    })
                ]
            ),
            Section(
                header: "appearance_title".localized,
                footer: "application_restart_required".localized,
                cells: [
                    .stickerStyle(
                        "sticker_style".localized,
                        repository.allStamps().sorted(by: { $0.count > $1.count }).first ?? Stamp.new,
                        settings.stickerStyle
                    ) { [weak self] newValue in
                        self?.settings.stickerStyle = newValue
                        self?.restartAppConfirmation()
                    }
                ]
            ),
            Section(
                header: "backup_title".localized,
                footer: "backup_footer".localized,
                cells: [
                    .button("backup_button".localized, { [weak self] in
                        self?.emailDataBackup()
                    }),
                ]
            ),
            Section(
                header: nil,
                footer: "Emojical, \(version), © 2022",
                cells: [
                    .button("please_rate".localized, { [weak self] in
                        self?.rateApp()
                    }),
                    .button("feedback_button".localized, { [weak self] in
                        self?.sendFeedback()
                    })
                ]
            ),
        ]

        if settings.reminderEnabled {
            let currentTime = calender.todayAtTime(hour: settings.reminderTime.hour, minute: settings.reminderTime.minute)
            data[0].cells.append(
                .time("reminde_me_at_time".localized, currentTime, { [weak self] newValue in
                    self?.updateReminderTime(to: newValue)
                })
            )
        }
        
        if showDeveloperMenu {
            data[2].cells.append(
                .navigate("Developer Options", { [weak self] in
                    self?.coordinator?.developerOptions()
                })
            )
        }
        
        view?.updateTitle("options_title".localized)
        view?.loadData(data)
    }

    private func updateReminderTime(to newValue: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
        settings.reminderTime = (comps.hour ?? 21, comps.minute ?? 0)

        // Update notifications
        notificationManager.refreshNotifications()
    }

    private func updateReminder(to newValue: Bool) {
        settings.reminderEnabled = newValue
        loadViewData()
        
        // Force notification manager to update reminder -
        // We use same notification as when stickers are added to the current date
        // because when that happens we also re-create reminder with a new text
        NotificationCenter.default.post(name: .todayStickersUpdated, object: nil)
    }
    
    private func rateApp() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1496301176?action=write-review")
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
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
    
    private func restartAppConfirmation() {

        let alert = UIAlertController(
            title: "sticker_style_restart".localized,
            message: nil,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "restart_button".localized,
            style: .destructive,
            handler: { (_) in
                abort()
        }))
        view?.viewController?.present(alert, animated: true, completion: nil)
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
