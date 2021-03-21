//
//  RecapReadyPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class RecapReadyPresenter: RecapReadyPresenterProtocol {

    // MARK: - DI

    private weak var view: RecapReadyView?

    // MARK: - Lifecycle

    init(
        message: String,
        view: RecapReadyView
    ) {
        self.view = view
        self.message = message
    }

    // MARK: - State
    
    private var message: String!

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
        view?.loadData(data: RecapReadyData(
            title: "week_recap_title".localized,
            text: message
        ))
    }
}
