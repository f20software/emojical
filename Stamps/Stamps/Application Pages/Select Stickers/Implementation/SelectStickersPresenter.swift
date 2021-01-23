//
//  SelectStickersPresenter.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/23/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

// import Foundation
import UIKit

class SelectStickersPresenter: SelectStickersPresenterProtocol {

    // MARK: - DI

    private weak var view: SelectStickersView?
    private let repository: DataRepository

    // MARK: - State
    
    private var selectedStickers: [Int64]

    // MARK: - Lifecycle

    init(
        view: SelectStickersView,
        repository: DataRepository,
        selectedStickers: [Int64]
    ) {
        self.view = view
        self.repository = repository
        self.selectedStickers = selectedStickers
    }

    // MARK: - SelectStickersPresenterProtocol
    
    /// Selected stickers changed
    var onChange: (([Int64]) -> Void)?

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
    }
    
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onStickerTapped = { [weak self] stickerId in
            self?.toggleSelectedSticker(with: stickerId)
        }
    }
    
    private func loadViewData() {
        let allStickers = repository.allStamps()
        let data: [SelectStickerData] = allStickers.map {
            return SelectStickerData(
                sticker: $0,
                selected: selectedStickers.contains($0.id ?? -1)
            )
        }
        
        view?.loadData(data)
        onChange?(selectedStickers)
    }
    
    private func toggleSelectedSticker(with id: Int64) {
        if selectedStickers.contains(id) {
            selectedStickers.removeAll { $0 == id }
        } else {
            selectedStickers.append(id)
        }
        loadViewData()
    }
}
