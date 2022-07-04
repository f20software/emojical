//
//  GoalsLibraryPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/6/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class GoalsLibraryPresenter: GoalsLibraryPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private weak var view: GoalsLibraryView?
    
    // MARK: - Data
    
    private var data: [GoalExampleData] = []
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        view: GoalsLibraryView
    ) {
        self.repository = repository
        self.view = view
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
        view?.onGoalTapped = { [weak self] goalName in
            self?.createGoal(goalName)
            self?.view?.dismiss()
        }
        view?.onCancelTapped = { [weak self] in
            self?.view?.dismiss()
        }
    }
    
    private func loadViewData() {
        view?.updateTitle("goals_library_title".localized)
        let sections = Array(Set(goalExamplesData.map({ $0.category.localized })))
        data = goalExamplesData.map({ GoalExampleData(
            category: $0.category.localized,
            name: $0.name.localized,
            description: $0.description.localized,
            direction: $0.direction,
            period: $0.period,
            limit: $0.limit,
            stickers: $0.stickers,
            extra: $0.extra
        )})
        view?.loadData(sections: sections, goals: data)
    }
    
    private func createSticker(_ data: StickerExampleData) -> Int64? {
        if let found = repository.stickerByLabel(data.emoji) {
            return found.id
        }

        do {
            let new = Stamp(
                name: data.name.localized,
                label: data.emoji,
                color: data.color
            )
            let saved = try repository.save(stamp: new)
            return saved.id
        }
        catch {}
        
        return nil
    }
    
    private func createGoal(_ name: String) {
        guard let goal = data.first(where: { $0.name == name }) else { return }

        let stickerIds = goal.stickers.compactMap({ createSticker($0) })
        _ = goal.extra.map({ createSticker($0) })
        
        do {
            let new = Goal(
                name: goal.name.localized,
                period: goal.period,
                direction: goal.direction,
                limit: goal.limit,
                stamps: stickerIds
            )
            try repository.save(goal: new)
        }
        catch {}
    }
}
