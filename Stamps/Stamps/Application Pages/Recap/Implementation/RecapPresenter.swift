//
//  TodayPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class RecapPresenter: RecapPresenterProtocol {

    // MARK: - DI

    private weak var view: RecapView?

    // MARK: - Lifecycle

    init(
        data: [AwardRecapData],
        view: RecapView
    ) {
        self.view = view
        self.data = data
    }

    // MARK: - State

    // All available stamps (to be shown in stamp selector)
    private var data: [AwardRecapData] = []
    
    /// Called when view finished initial loading.
    func onViewDidLoad() {
        
        setupView()
    }
    
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        
    }
    
    private func loadViewData() {
        view?.loadRecapData(data: data)
    }
}
