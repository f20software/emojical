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
    private let dataBuilder: CalendarDataBuilder

    // MARK: - Lifecycle

    init(
        view: GoalView,
        coordinator: GoalCoordinatorProtocol,
        awardManager: AwardManager,
        repository: DataRepository,
        goal: Goal?,
        presentation: PresentationMode,
        editing: Bool
    ) {
        self.view = view
        self.coordinator = coordinator
        self.awardManager = awardManager
        self.repository = repository
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: CalendarHelper.shared
        )

        self.goal = goal ?? Goal.new
        self.presentationMode = presentation
        self.isEditing = editing
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
            // We potentially can have here different logic, for exmaple:
            // if we're in the view->edit mode, "Cancel" could bring
            // us back to the viewing mode, but then we need to carefully review
            // what will happen with current `goal` object, since we can update initial
            // state of it when selecting stickers 
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
        view?.onSelectStickersTapped = { [weak self] in
            self?.selectStickers()
        }
        view?.onGoalChanged = { [weak self] in
            self?.validateInputAndUpdateView()
        }
    }
    
    private func confirmGoalDelete() {
        if goal.count <= 0 {
            deleteAndDismiss()
        }
        
        let confirm = UIAlertController(
            title: "woah_title".localized,
            message: "goal_delete_confirmation".localized,
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
        guard let id = goal.id else { return }

        do {
            // Mark goal as deleted
            goal.deleted = true
            try repository.save(goal: goal)
            
            // Remove any awards that were given for this goal in the current week,
            // since week is not closed yet
            let week = CalendarHelper.Week(Date())
            repository.deleteAwards(from: week.firstDay, to: week.lastDay, goalId: id)
        }
        catch {}

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
        updateTitle()
        view.enableDoneButton(goal.isValid)
    }
    
    private func updateTitle() {
        let title = (goal.name.isEmpty && presentationMode == .modal) ?
            "new_goal_title".localized : goal.name
        view?.updateTitle(title)
    }

    // Create a load view data based on editing mode
    private func loadViewData() {
        guard let view = view else { return }
        
        let progress = awardManager.currentProgressFor(goal)
        let stamp = repository.stampBy(id: goal.stamps.first)

        updateTitle()

        if isEditing {
            let data = GoalEditData(
                goal: goal,
                stickers: repository.stampLabelsFor(goal: goal)
            )
            if presentationMode == .modal {
                view.loadData([.edit(data)])
            } else {
                view.loadData([.edit(data), .deleteButton])
            }
            view.enableDoneButton(goal.isValid)
        } else {
            let data = GoalViewData(
                details: Language.goalDescription(goal),
                stickers: repository.stampLabelsFor(goal: goal),
                progressText: Language.goalCurrentProgress(
                    period: goal.period,
                    direction: goal.direction,
                    progress: progress,
                    limit: goal.limit
                ),
                awardIcon: AwardIconData(stamp: stamp),
                goalIcon: GoalIconData(stamp: stamp, goal: goal, progress: progress)
            )
            
            var cells: [GoalDetailsElement] = [.view(data)]
            if let history = dataBuilder.historyFor(goal: goal.id, limit: 12) {
                cells.append(.reached(history.reached))
                if history.chart.points.count > 2 {
                    cells.append(.chart(history.chart))
                }
            }
            
            view.loadData(cells)
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
