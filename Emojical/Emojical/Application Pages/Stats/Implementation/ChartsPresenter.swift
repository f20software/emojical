//
//  ChartsPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class ChartsPresenter: ChartsPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let awardManager: AwardManager
    private let stampsListener: StampsListener
    private let calendar: CalendarHelper
    private let dataBuilder: CalendarDataBuilder

    private weak var view: ChartsView?
    private weak var coordinator: ChartsCoordinatorProtocol?

    // MARK: - State
    
    /// This list is baked in
    private let data: [ChartType] = [.monthlyStickers, .goalStreak]

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        awardManager: AwardManager,
        stampsListener: StampsListener,
        calendar: CalendarHelper,
        view: ChartsView,
        coordinator: ChartsCoordinatorProtocol
    ) {
        self.repository = repository
        self.awardManager = awardManager
        self.stampsListener = stampsListener
        self.calendar = calendar
        self.view = view
        self.coordinator = coordinator
        
        self.dataBuilder = CalendarDataBuilder(
            repository: repository,
            calendar: calendar
        )
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
        
        view?.onChartTapped = { [weak self] chartIndex in
            guard let self = self else { return }
            self.coordinator?.showChart(self.data[chartIndex])
        }
    }
    
    private func loadViewData() {
        view?.updateTitle("charts_title".localized)
        
        view?.loadChartsData(data: data.map {
            ChartTypeDetails(
                type: $0,
                title: $0.title
            )
        })
    }
}