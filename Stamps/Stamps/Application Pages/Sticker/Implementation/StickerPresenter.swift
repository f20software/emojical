//
//  StickerPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension Stamp {
    
    // Sticker editing validation
    var isValid: Bool {
        // Should have some emoji
        guard self.label.lengthOfBytes(using: .utf8) > 0 else { return false }
        
        return true
    }
}

class StickerPresenter: StickerPresenterProtocol {

    // MARK: - DI

    private weak var view: StickerViewProtocol?
    private let awardManager: AwardManager
    private let coordinator: StickerCoordinatorProtocol
    private let repository: DataRepository

    // MARK: - Lifecycle

    init(
        view: StickerViewProtocol,
        coordinator: StickerCoordinatorProtocol,
        awardManager: AwardManager,
        repository: DataRepository,
        sticker: Stamp?,
        presentation: PresentationMode
    ) {
        self.view = view
        self.coordinator = coordinator
        self.awardManager = awardManager
        self.repository = repository
        self.sticker = sticker ?? Stamp.new
        self.presentationMode = presentation
        self.isEditing = (sticker == nil)
    }

    // MARK: - State

    // Sticker object
    private var sticker: Stamp!
    
    // Presentation mode (pushed or popped as modal)
    private var presentationMode: PresentationMode!

    // Whether we're editing goal or viewing it
    private var isEditing: Bool!
    
    // MARK: - View lifecycle
    
    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
    }
    
    func onViewWillAppear() {
        view?.setEditing(isEditing, animated: false)
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onEditTapped = { [weak self] in
            self?.setViewEditing(true)
        }
        view?.onCancelTapped = { [weak self] in
            // We potentially can have here different logic, for exmaple:
            // if we're in the view->edit mode, "Cancel" could bring
            // us back to the viewing mode
            self?.view?.dismiss(from: self!.presentationMode)
        }
        view?.onDoneTapped = { [weak self] in
            self?.saveViewData()
            if self?.presentationMode == .modal {
                self?.view?.dismiss(from: self!.presentationMode)
            } else {
                self?.setViewEditing(false)
                self?.loadViewData()
            }
        }
        view?.onDeleteTapped = { [weak self] in
            self?.confirmGoalDelete()
        }
        view?.onNewGoalTapped = { [weak self] in
            guard let id = self?.sticker.id else { return }
            self?.coordinator.newGoal(with: id)
        }
        view?.onStickerChanged = { [weak self] in
            self?.validateInputAndUpdateView()
        }
    }
    
    private func confirmGoalDelete() {
        if sticker.count > 0 {
            let confirm = UIAlertController(title: "Woah!", message: "\(sticker.statsDescription) Are you sure you want to delete it?", preferredStyle: .actionSheet)
            confirm.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                self.deleteAndDismiss()
            }))
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                confirm.dismiss(animated: true, completion: nil)
            }))
            (view as! UIViewController).present(confirm, animated: true, completion: nil)
        }
        else {
            deleteAndDismiss()
        }
    }
    
    private func deleteAndDismiss() {
        sticker.deleted = true
        try! repository.save(stamp: sticker)
        view?.dismiss(from: presentationMode)
    }

    private func saveViewData() {
        view?.update(to: &sticker)
        try! repository.save(stamp: sticker)
    }
    
    private func setViewEditing(_ editing: Bool) {
        isEditing = editing
        view?.setEditing(editing, animated: true)
        loadViewData()
    }

    private func validateInputAndUpdateView() {
        guard let view = view else { return }

        view.update(to: &sticker)
        updateTitle()
        view.updateIcon(sticker)
        view.enableDoneButton(sticker.isValid)
    }
    
    private func updateTitle() {
        let title = (sticker.name.isEmpty && presentationMode == .modal)  ? "New Sticker" : sticker.name
        view?.updateTitle(title)
    }
    
    // Create a load view data based on editing mode
    private func loadViewData() {
        // First set title and then check whether we're in edit or viewing mode
        updateTitle()
        
        if isEditing {
            loadViewDataEditing()
        } else {
            loadViewDataViewing()
        }
    }

    // Form is in viewing mode
    private func loadViewDataViewing() {
        guard let view = view else { return }

        // Build usage text
        let goals = repository.goalsUsedStamp(sticker.id)
        var usageText = ""
        if goals.count == 0 {
            usageText = "You haven't created a goal yet with this sticker."
        } else if goals.count == 1 {
            usageText = "Sticker is used in \'\(goals.first?.name ?? "")\' goal."
        } else {
            let text = goals.map({ "'\($0.name)'" }).sentence
            usageText = "Sticker is used in \(text) goals."
        }
        
        var data: [StickerDetailsElement] = [.view(
            StickerViewData(
                sticker: sticker,
                statistics: sticker.statsDescription,
                usage: usageText
            )
        )]
        if goals.count == 0 {
            data.append(.newGoalButton)
        }
        view.loadData(data)
    }

    // Form is in editing mode
    private func loadViewDataEditing() {
        guard let view = view else { return }

        let data = StickerEditData(
            sticker: sticker
        )

        if presentationMode == .modal {
            view.loadData([.edit(data)])
            // For newly created emoji - help user understand what needs to be done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                view.focusOnEmoji()
            })
        } else {
            view.loadData([.edit(data), .deleteButton])
        }
        
        view.enableDoneButton(sticker.isValid)
    }
}
