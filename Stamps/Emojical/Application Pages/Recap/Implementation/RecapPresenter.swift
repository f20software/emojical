//
//  RecapPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/25/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

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

    /// Awards (reached and not reached)
    private var data: [AwardRecapData] = []
    
    /// Highlighted award (showing details)
    private var highlightedItem: IndexPath?

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
    }
    
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onAwardTapped = { [weak self] (indexPath) in
            self?.highlightAward(at: indexPath)
        }
    }
    
    private func loadViewData() {
        view?.loadRecapData(data: data)
    }
    
    private func highlightAward(at indexPath: IndexPath) {
        // Tap on selected cell? Deselect it
        if highlightedItem == indexPath {
            view?.highlightAward(at: indexPath, highlight: false)
            highlightedItem = nil
            return
        }
        
        if let old = highlightedItem {
            view?.highlightAward(at: old, highlight: false)
        }
        highlightedItem = indexPath
        view?.highlightAward(at: indexPath, highlight: true)
    }
}
