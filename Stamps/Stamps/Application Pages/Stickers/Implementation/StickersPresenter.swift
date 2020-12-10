//
//  StickersPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class StickersPresenter: StickersPresenterProtocol {

    // MARK: - DI

    private let repository: DataRepository
    private let stampsListener: StampsListener
    private weak var view: StickersView?
    
    // MARK: - State

    private var stamps: [Stamp] = []
    
    private var goals: [Goal] = []
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        view: StickersView
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.view = view
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
        
        // Load initial set of data
        stamps = repository.allStamps()
        goals = repository.allGoals()

        // Subscribe to stamp listner in case stamps array ever changes
        stampsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            guard let self = self else { return }
            
            self.stamps = self.repository.allStamps()
            self.loadViewData()
        })
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
    }
    
    private func loadViewData() {
        view?.loadData(stickers: stamps, goals: goals)
    }
}
