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
    private weak var view: ChartsView?
    private weak var coordinator: ChartsCoordinatorProtocol?

    // MARK: - State
    
    /// This list is baked in
    private let data: [ChartType] = [.monthlyStickers, .goals]

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        view: ChartsView,
        coordinator: ChartsCoordinatorProtocol
    ) {
        self.repository = repository
        self.view = view
        self.coordinator = coordinator
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
        view?.loadChartsData(data)
    }
}
