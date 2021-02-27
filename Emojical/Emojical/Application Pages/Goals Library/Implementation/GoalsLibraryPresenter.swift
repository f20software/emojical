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
                StickerExampleData(emoji: "⚽️", name: "Soccer", color: UIColor(named: "emojiGreen")!)
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
                StickerExampleData(emoji: "🧘", name: "Yoga", color: UIColor(named: "emojiYellow")!),
                StickerExampleData(emoji: "⚽️", name: "Soccer", color: UIColor(named: "emojiGreen")!),
                StickerExampleData(emoji: "⛹🏻‍♀️", name: "Basketball", color: UIColor(named: "emojiLightGreen")!),
                StickerExampleData(emoji: "🚴🏻", name: "Bike", color: UIColor(named: "emojiLightGreen")!),
                StickerExampleData(emoji: "🏓", name: "Ping-pong", color: UIColor(named: "emojiGreen")!),
            ],
            extra: []
        ),
        GoalExampleData(
            category: "Food",
            name: "Eat Less Red Meat",
            description: "Record food you eat - 🥩,🐣,🐟,🥦. And try to have 3 of fewer red meats per week.",
            direction: .negative,
            period: .week,
            limit: 3,
            stickers: [
                StickerExampleData(emoji: "🥩", name: "Steak", color: UIColor(named: "emojiRed")!),
            ],
            extra: [
                StickerExampleData(emoji: "🐣", name: "Chicken", color: UIColor(named: "emojiGreen")!),
                StickerExampleData(emoji: "🐟", name: "Fish", color: UIColor(named: "emojiGreen")!),
                StickerExampleData(emoji: "🥦", name: "Veggies", color: UIColor(named: "emojiLightGreen")!),
            ]
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
        let sections = Array(Set(data.map({ $0.category })))
        view?.loadData(sections: sections, goals: data)
    }
    
    private func createSticker(_ data: StickerExampleData) -> Int64? {
        if let found = repository.stampByLabel(label: data.emoji) {
            return found.id
        }

        do {
            let new = Stamp(
                name: data.name,
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
