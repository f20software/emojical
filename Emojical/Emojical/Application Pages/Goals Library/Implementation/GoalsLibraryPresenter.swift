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
    
    // MARK: - Built-in data
    
    private let data: [GoalExampleData] = [
        GoalExampleData(
            category: "Health",
            name: "Play Soccer",
            description: "Record your soccer practices and try to get to 3 times per week.",
            direction: .positive,
            period: .week,
            limit: 3,
            stickers: [
                StickerExampleData(emoji: "⚽️", name: "Soccer", color: .green)
            ],
            extra: []
        ),
        GoalExampleData(
            category: "Health",
            name: "Be Active",
            description: "Record your activities - 🧘,⚽️,⛹🏻‍♀️,🚴🏻,🏓. Try to do this 5 times per week.",
            direction: .positive,
            period: .week,
            limit: 5,
            stickers: [
                StickerExampleData(emoji: "🧘", name: "Yoga", color: .yellow),
                StickerExampleData(emoji: "⚽️", name: "Soccer", color: .green),
                StickerExampleData(emoji: "⛹🏻‍♀️", name: "Basketball", color: .lightGreen),
                StickerExampleData(emoji: "🚴🏻", name: "Bike", color: .lightGreen),
                StickerExampleData(emoji: "🏓", name: "Ping-pong", color: .green),
            ],
            extra: []
        )
    ]
    
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
        view?.loadData(sections: data.map({ $0.category }), goals: data)
    }
    
    private func createGoal(_ name: String) {
        guard let goal = data.first(where: { $0.name == name }) else { return }

        var stickerIds = [Int64]()
        for sticker in goal.stickers {
            let found = repository.stampByLabel(label: sticker.emoji)
            if let id = found?.id {
                stickerIds.append(id)
            } else {
                do {
                    let new = Stamp(
                        name: sticker.name,
                        label: sticker.emoji,
                        color: UIColor(hex: sticker.color.rawValue)
                    )
                    let saved = try repository.save(stamp: new)
                    stickerIds.append(saved.id!)
                }
                catch {}
            }
        }
        
        do {
            let new = Goal(
                name: goal.name,
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
