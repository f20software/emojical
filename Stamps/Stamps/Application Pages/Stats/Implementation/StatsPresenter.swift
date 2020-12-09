//
//  StatsPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class StatsPresenter: StatsPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let stampsListener: StampsListener
    private let awardsListener: AwardsListener
    private let calendar: CalendarHelper
    private let awardManager: AwardManager
    private weak var view: StatsView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        awardsListener: AwardsListener,
        awardManager: AwardManager,
        calendar: CalendarHelper,
        view: StatsView
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.awardsListener = awardsListener
        self.awardManager = awardManager
        self.calendar = calendar
        self.view = view
        
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: calendar
        )
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
    }
    
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {

        view?.onNextWeekTapped = { [weak self] in
//            self?.advanceWeek(by: 1)
        }
        view?.onPrevWeekTapped = { [weak self] in
//            self?.advanceWeek(by: -1)
        }
    }
    
    private func loadViewData() {
        // Title and nav bar
//        view?.setTitle(to: dataBuilder.weekTitleForWeek(weekIndex))
//        view?.showNextWeekButton(weekIndex < (calendar.currentWeeks.count-1))
//        view?.showPrevWeekButton(weekIndex > 0)
//
//        // Awards strip on the top
//        loadAwardsData()
//
//        // Column data
//        view?.loadDaysData(data: model)
//
//        // Stamp selector data
//        loadStampSelectorData()
    }
}

// MARK: - Specs
fileprivate struct Specs {

}
