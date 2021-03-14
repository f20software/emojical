//
//  WelcomePresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class WelcomePresenter: WelcomePresenterProtocol {

    // MARK: - DI

    private weak var view: WelcomeView?
    
    // MARK: - Data
    
    private var bottomMargin: Float
    private var content: CoachMessage

    // MARK: - Lifecycle

    init(
        view: WelcomeView,
        content: CoachMessage,
        bottomMargin: Float
    ) {
        self.view = view
        self.content = content
        self.bottomMargin = bottomMargin
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
        view?.setBottomMargin(margin: bottomMargin)
    }
    
    private func loadViewData() {
        switch content {
        case .onboarding1:
            view?.loadData(data: WelcomeData(
                messages: [
                    "onboarding_1_1".localized,
                    "onboarding_1_2".localized
                ],
                buttonText: "got_it_button".localized
            ))

        case .onboarding2:
            view?.loadData(data: WelcomeData(
                messages: [
                    "onboarding_2".localized
                ],
                buttonText: "got_it_button".localized
            ))

        default:
            break
        }
    }
}
