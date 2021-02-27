//
//  CongratsPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/13/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class CongratsPresenter: CongratsPresenterProtocol {

    // MARK: - DI

    private weak var view: CongratsView?
    private var repository: DataRepository!
    private var dataBuilder: CalendarDataBuilder!

    // MARK: - Lifecycle

    init(
        data: Award,
        view: CongratsView,
        repository: DataRepository
        
    ) {
        self.view = view
        self.data = data
        self.repository = repository
        self.dataBuilder = CalendarDataBuilder(repository: repository, calendar: CalendarHelper.shared)
    }

    // MARK: - State

    /// Awards (reached and not reached)
    private var data: Award?
    
    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
    }
    
    func onViewWillAppear() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
    }
    
    private func loadViewData() {
        guard let award = data,
              let goal = repository.goalBy(id: award.goalId) else { return }
            
        let stamp = repository.stampBy(id: goal.stamps.first)
        let history = dataBuilder.historyFor(goal: goal.id, limit: 12)
        let text = Language.positiveCheerMessage(
            goalName: award.goalName,
            streak: history?.reached.streak,
            count: history?.reached.count
        )
        
        view?.loadData(data: CongratsData(
            title: "awesome_title".localized,
            text: text,
            goalIcon: GoalIconData(stamp: stamp, goal: goal, progress: 0 /* don't really care*/),
            awardIcon: AwardIconData(stamp: stamp)
        ))
    }
}
