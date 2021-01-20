//
//  GoalPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class GoalPresenter: GoalPresenterProtocol {

    // MARK: - DI

    private weak var view: GoalView?
    private let awardManager: AwardManager
    private let repository: DataRepository

    // MARK: - Lifecycle

    init(
        view: GoalView,
        awardManager: AwardManager,
        repository: DataRepository,
        goal: Goal?,
        presentation: PresentationMode
    ) {
        self.view = view
        self.awardManager = awardManager
        self.repository = repository
        self.goal = goal ?? Goal.new
        self.presentationMode = presentation
        self.isEditing = (presentation == .modal)
    }

    // MARK: - State

    private var goal: Goal!
    
    private var presentationMode: PresentationMode!

    private var isEditing: Bool!
    
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
    
    private func loadViewData() {
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
            view?.loadGoalDetails(.edit(data))
        } else {
            let data = GoalViewData(
                title: goal.name,
                details: goal.details,
                statis: goal.statsDescription,
                stickers: repository.stampLabelsFor(goal),
                progressText: goal.descriptionForCurrentProgress(progress),
                award: award,
                progress: currentProgress
            )
            view?.loadGoalDetails(.view(data))
        }
    }
}
