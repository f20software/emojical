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

class WelcomePresenter: WelcomePresenterProtocol {

    // MARK: - DI

    private weak var view: WelcomeView?

    // MARK: - Lifecycle

    init(
        view: WelcomeView
    ) {
        self.view = view
    }

    // MARK: - State

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
        view?.loadData(data: WelcomeData(
            title: "welcome_title".localized,
            text: "welcome_description".localized,
            bottomMargin: 0
        ))
    }
}
