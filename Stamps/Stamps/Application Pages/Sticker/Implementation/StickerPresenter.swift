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

    // Goal object
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
            if self?.presentationMode == .modal {
                self?.view?.dismiss(from: self!.presentationMode)
            } else {
                self?.setViewEditing(false)
            }
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
        view.updateTitle(sticker.name)
        view.enableDoneButton(sticker.isValid)
    }
    
    // Create a load view data based on editing mode
    private func loadViewData() {
        guard let view = view else { return }

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
        
        if isEditing {
            let data = StickerEditData(
                sticker: sticker
            )
            if presentationMode == .modal {
                view.loadStickerData([.edit(data)])
            } else {
                view.loadStickerData([.edit(data), .deleteButton])
            }
            view.enableDoneButton(sticker.isValid)
        } else {
            let data = StickerViewData(
                sticker: sticker,
                statistics: sticker.statsDescription,
                usage: usageText
            )
            view.updateTitle(sticker.name)
            view.loadStickerData([.view(data)])
        }
    }
}
