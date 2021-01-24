//
//  GoalPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

extension Goal {
    
    // Goal editing validation
    var isValid: Bool {
        // Should have not empty name
        guard name.lengthOfBytes(using: .utf8) > 0 else { return false }
        
        // Should have some stickers selected
        guard stamps.count > 0 else { return false }
        
        // Should have some positive limit
        guard limit > 0 else { return false }
        
        // Is goal reachable / or realistic
        if period == .week && limit > 7 {
            return false
        }
        if period == .month && limit > 31 {
            return false
        }
        
        return true
    }
}

class GoalPresenter: GoalPresenterProtocol {

    // MARK: - DI

    private weak var view: GoalView?
    private let awardManager: AwardManager
    private let coordinator: GoalCoordinatorProtocol
    private let repository: DataRepository

    // MARK: - Lifecycle

    init(
        view: GoalView,
        coordinator: GoalCoordinatorProtocol,
        awardManager: AwardManager,
        repository: DataRepository,
        goal: Goal?,
        presentation: PresentationMode
    ) {
        self.view = view
        self.coordinator = coordinator
        self.awardManager = awardManager
        self.repository = repository
        self.goal = goal ?? Goal.new
        self.presentationMode = presentation
        self.isEditing = (presentation == .modal)
    }

    // MARK: - State

    // Goal object
    private var goal: Goal!
    
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
        view?.onSelectStickersTapped = { [weak self] in
            self?.selectStickers()
        }
        view?.onGoalChanged = { [weak self] in
            self?.validateInputAndUpdateView()
        }
    }
    
    private func confirmGoalDelete() {
        if goal.count > 0 {
            let confirm = UIAlertController(title: "Woah!", message: "\(goal.statsDescription) Are you sure you want to delete it?", preferredStyle: .actionSheet)
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
        goal.deleted = true
        try! repository.save(goal: goal)
        view?.dismiss(from: presentationMode)
    }

    private func saveViewData() {
        view?.update(to: &goal)
        try! repository.save(goal: goal)
    }
    
    private func setViewEditing(_ editing: Bool) {
        isEditing = editing
        view?.setEditing(editing, animated: true)
        loadViewData()
    }

    private func validateInputAndUpdateView() {
        guard let view = view else { return }

        view.update(to: &goal)
        view.updateTitle(goal.name)
        view.enableDoneButton(goal.isValid)
    }
    
    // Create a load view data based on editing mode
    private func loadViewData() {
        guard let view = view else { return }
        
        let progress = awardManager.currentProgressFor(goal)
        let stamp = repository.stampById(goal.stamps.first)
        let currentProgress = GoalAwardData(
            goal: goal,
            progress: progress,
            stamp: stamp
        )
        let award = GoalAwardData(
            goal: goal,
            stamp: stamp
        )

        if isEditing {
            let data = GoalEditData(
                goal: goal,
                stickers: repository.stampLabelsFor(goal),
                award: award
            )
            if presentationMode == .modal {
                view.loadGoalData([.edit(data)])
            } else {
                view.loadGoalData([.edit(data), .deleteButton])
            }
            view.enableDoneButton(goal.isValid)
        } else {
            let data = GoalViewData(
                details: goal.details,
                statis: goal.statsDescription,
                stickers: repository.stampLabelsFor(goal),
                progressText: goal.descriptionForCurrentProgress(progress),
                award: award,
                progress: currentProgress
            )
            view.updateTitle(goal.name)
            view.loadGoalData([.view(data)])
        }
    }
    
    // Navigate to select stickers view and configure callback
    private func selectStickers() {
        coordinator.selectStickers(goal.stamps) { [weak self] (updateIds) in
            self?.goal.stamps = updateIds
            self?.loadViewData()
        }
    }
}
