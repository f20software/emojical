//
//  StickerPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension Sticker {
    
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
    private let dataBuilder: CalendarDataBuilder

    // MARK: - Lifecycle

    init(
        view: StickerViewProtocol,
        coordinator: StickerCoordinatorProtocol,
        awardManager: AwardManager,
        repository: DataRepository,
        sticker: Sticker?,
        presentation: PresentationMode
    ) {
        self.view = view
        self.coordinator = coordinator
        self.awardManager = awardManager
        self.repository = repository
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: CalendarHelper.shared
        )

        self.sticker = sticker ?? Sticker.new
        self.presentationMode = presentation
        self.isEditing = (sticker == nil)
    }

    // MARK: - State

    // Sticker object
    private var sticker: Sticker!
    
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
            self?.confirmStickerDelete()
        }
        view?.onNewGoalTapped = { [weak self] in
            guard let sticker = self?.sticker else { return }
            self?.coordinator.newGoal(with: sticker)
        }
        view?.onStickerChanged = { [weak self] in
            self?.validateInputAndUpdateView()
        }
    }
    
    private func confirmStickerDelete() {
        if sticker.count <= 0 {
            deleteAndDismiss()
            return
        }
        
        let confirm = UIAlertController(
            title: "woah_title".localized,
            message: "sticker_delete_confirmation".localized,
            preferredStyle: .actionSheet)
        
        confirm.addAction(UIAlertAction(
            title: "delete_button".localized,
            style: .destructive, handler: { (_) in
            self.deleteAndDismiss()
        }))
        
        confirm.addAction(UIAlertAction(
            title: "cancel_button".localized,
            style: .cancel, handler: { (_) in
            confirm.dismiss(animated: true, completion: nil)
        }))
        (view as! UIViewController).present(confirm, animated: true, completion: nil)
    }
    
    private func deleteAndDismiss() {
        guard let id = sticker.id else { return }

        // Mark sticker as deleted
        sticker.deleted = true
        do {
            let goalIds = repository.goalsUsedStamp(id).compactMap({ $0.id })
            try repository.save(stamp: sticker)
            // Remove this sticker from all goals that it was assigned to
            repository.removeSticker(id, from: goalIds)
        }
        catch {}

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
        let title = (sticker.name.isEmpty && presentationMode == .modal) ?
            "new_sticker_title".localized : sticker.name
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

        let goals = repository.goalsUsedStamp(sticker.id)
        var data: [StickerDetailsElement] = [.view(
            StickerViewData(
                sticker: sticker,
                usage: Language.stickerUsedInGoals(goals)
            )
        )]

        if let history = dataBuilder.historyFor(sticker: sticker.id) {
            data.append(.used(history))
        }
        
        data.append(.deleteButton(
            sticker.count > 0 ? "delete_sticker_description".localized : nil))

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
            view.loadData([
                .edit(data),
                .deleteButton("delete_sticker_description".localized)])
        }
        
        view.enableDoneButton(sticker.isValid)
    }
}
