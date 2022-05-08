//
//  DeveloperPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class DeveloperPresenter: NSObject, DeveloperPresenterProtocol {

    // MARK: - DI

    private weak var view: DeveloperView?
    private weak var settings: LocalSettings!
    private weak var repository: DataRepository!
    private weak var awards: AwardManager!

    // MARK: - State

    // MARK: - Lifecycle

    init(
        view: DeveloperView,
        repository: DataRepository,
        awards: AwardManager,
        settings: LocalSettings
    ) {
        self.view = view
        self.repository = repository
        self.awards = awards
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
        let stickersCount = repository.allStamps().count
        let stickersDeletedCount = repository.allStamps(includeDeleted: true).count - stickersCount
        let goalsCount = repository.allGoals().count
        let goalsDeletedCount = repository.allGoals(includeDeleted: true).count - goalsCount
        let diaryCount = repository.diaryForDateInterval(
            from: repository.getFirstDiaryDate() ?? Date(),
            to: repository.getLastDiaryDate() ?? Date()).count
        let awardsCount = repository.allAwards().count
        let lastWeek = repository.lastWeekUpdate != nil ? repository.lastWeekUpdate!.databaseKey : "-"
        let lastMonth = repository.lastMonthUpdate != nil ? repository.lastMonthUpdate!.databaseKey : "-"

        let data: [Section] = [
            Section(
                header: "Settings",
                footer: nil,
                cells: [
                    .text(CoachMessage.onboarding1.stringValue, settings.isOnboardingSeen(.onboarding1).description),
                    .text(CoachMessage.onboarding2.stringValue, settings.isOnboardingSeen(.onboarding2).description),
                    .text("reminderEnalbed", settings.reminderEnabled.description),
                    .text("reminderTime", "\(settings.reminderTime.hour):\(settings.reminderTime.minute)"),
                ]
            ),
            Section(
                header: "Database",
                footer: nil,
                cells: [
                    .text("Last Week Closed", "\(lastWeek)"),
                    .text("Last Month Closed", "\(lastMonth)"),
                    .text("Stickers (Deleted)", "\(stickersCount) (\(stickersDeletedCount))"),
                    .text("Goals (Deleted)", "\(goalsCount) (\(goalsDeletedCount))"),
                    .text("Stickers Used", "\(diaryCount)"),
                    .text("Awards", "\(awardsCount)"),
                    .button("Clear Database", {
                        self.confirmAndDeleteDatabase()
                    }),
                    .button("Create Demo Database", {
                        self.createDemoDatabase()
                        self.loadViewData()
                    }),
                    .button("Create Initial Database", {
                        self.createIinitialDatabase()
                        self.loadViewData()
                    }),
                ]
            ),
            Section(
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
                    .button("Start Onboarding", {
                        CoachMessageManager.shared.mockMessage(.onboarding1)
                        // CoachMessageManager.shared.mockMessage(.onboarding2)
                    }),
                ]
            ),
            Section(
                header: "Log File",
                footer: nil,
                cells: [
                    .button("Delete Log File (\(logFileSize))...", {
                        self.deleteLogFile()
                    }),
                    .button("Email Log File...", {
                        self.emailLogFile()
                    }),
                ]
            ),
        ]
        
        view?.loadData(data)
    }

    private func deleteLogFile() {
        guard let file = AppDelegate.applicationLogFile else { return }
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: file))
        } catch let error as NSError {
            NSLog("Failed to delete log file \(error.domain)")
        }
        loadViewData()
    }

    private var logFileSize: String {
        let unknown = "???"
        
        guard
            let file = AppDelegate.applicationLogFile,
            let attrs = try? FileManager.default.attributesOfItem(atPath: file),
            let size = attrs[.size] as? Int64 else {
            return unknown
        }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: size)
    }
    
    private func emailLogFile() {
        guard let file = AppDelegate.applicationLogFile else { return }
        emailFile(
            attachment: URL(fileURLWithPath: file),
            fileName: "application.log"
        )
    }
    
    private func confirmAndDeleteDatabase() {
        let alert = UIAlertController(title: "Confirm", message: "This is cannot be undone. Please confirm that you want to delelte all records from the databas.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            self.repository.clearDatabase()
            self.loadViewData()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        view?.viewController?.present(alert, animated: true, completion: nil)
    }

    private func createDemoDatabase() {
        repository.createDemoEntries(
            from: Date())
        awards.recalculateOnAppResume()
    }

    private func createIinitialDatabase() {
        repository.createInitialStickers()
        awards.recalculateOnAppResume()
    }
}
    
// MARK: - MFMailComposeViewControllerDelegate

extension DeveloperPresenter: MFMailComposeViewControllerDelegate {
    
    private var mailComposer: MFMailComposeViewController? {
        guard MFMailComposeViewController.canSendMail() else {
            return nil
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        return mail
    }
    
    private func emailFile(attachment: URL, fileName: String) {
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

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
