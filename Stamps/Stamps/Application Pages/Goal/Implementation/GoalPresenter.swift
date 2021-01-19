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

    enum Presentation {
        /// Modal presentation - editing new goal initially
        case modal
        /// Push presentation - viewing goal initially, can switch to edit mode
        case push
    }

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
        presentation: Presentation
    ) {
        self.view = view
        self.awardManager = awardManager
        self.repository = repository
        self.goal = goal
        self.presentationMode = presentation
        self.isEditing = (presentation == .modal)
    }

    // MARK: - State

    private var goal: Goal?
    
    private var presentationMode: Presentation!

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
                self?.view?.dismiss()
            } else {
                self?.setViewEditing(false)
            }
        }
        view?.onDoneTapped = { [weak self] in
            self?.saveViewData()
            if self?.presentationMode == .modal {
                self?.view?.dismiss()
            } else {
                self?.setViewEditing(false)
            }
        }
    }
    
    private func saveViewData() {
        print("SAVE GOAL VIEW DATA")
    }
    
    private func setViewEditing(_ editing: Bool) {
        isEditing = editing
        view?.setEditing(editing, animated: true)
        loadViewData()
    }
    
    private func loadViewData() {
        let goal = self.goal ?? Goal(
            id: nil,
            name: "New Goal",
            period: .week,
            direction: .positive,
            limit: 5,
            stamps: []
        )
        let progress = awardManager.currentProgressFor(goal)
        let stamp = repository.stampById(goal.stamps.first)
        let award = GoalAwardData(
            goal: goal,
            progress: progress,
            stamp: stamp
        )
        
        if isEditing {
            view?.loadGoal(
                data: [.edit(GoalDetailsData(goal: goal, progress: progress, award: award))]
            )
        } else {
            view?.loadGoal(
                data: [.details(GoalDetailsData(goal: goal, progress: progress, award: award))]
            )
        }
    }
}
