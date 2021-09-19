//
//  MonthlyStickerBoxPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class MonthlyStickerBoxPresenter: ChartPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let stampsListener: StampsListener
    private let calendar: CalendarHelper
    private weak var view: MonthlyStickerBoxView?
    
    // Private instance of the data builder
    private let dataBuilder: CalendarDataBuilder

    // MARK: - State

    /// Copy of all stamps - used to build data model for view to show
    private var stamps = [Stamp]()
    
    /// Selected month
    private var selectedMonth = CalendarHelper.Month(Date().byAddingDays(-20))

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        calendar: CalendarHelper,
        view: MonthlyStickerBoxView
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
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

        // Load initial set of data
        stamps = repository.allStamps()
        
        // Subscribe to stamp listner in case stamps array ever changes
        stampsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            guard let self = self else { return }
            
            self.stamps = self.repository.allStamps().sorted(by: { $0.count > $1.count })
            self.loadViewData()
        })
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onNextButtonTapped = { [weak self] in
            self?.advancePeriod(by: 1)
        }
        view?.onPrevButtonTapped = { [weak self] in
            self?.advancePeriod(by: -1)
        }
    }
    
    private func loadViewData() {
        view?.showNextPrevButtons(
            showPrev: dataBuilder.canMoveBackward(selectedMonth),
            showNext: dataBuilder.canMoveForward(selectedMonth)
        )

        let data = dataBuilder.emptyStatsData(for: selectedMonth, stamps: stamps)
        view?.loadMonthData(header: selectedMonth.label, data: data)
    }
    
    // Move today's date one week to the past or one week to the future
    private func advancePeriod(by delta: Int) {
        selectedMonth = CalendarHelper.Month(selectedMonth.firstDay.byAddingMonth(delta))
        // Update view
        loadViewData()
    }
}
