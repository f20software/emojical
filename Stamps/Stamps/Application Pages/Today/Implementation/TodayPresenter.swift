//
//  TodayPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/6/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class TodayPresenter: TodayPresenterProtocol {

    // MARK: - DI

    let repository: DataRepository
    weak var view: TodayView?

    // MARK: - State


    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        view: TodayView
    ) {
        self.repository = repository
        self.view = view
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        

    }

}
