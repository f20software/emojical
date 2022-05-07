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
    private let goalsListener: GoalsListener
    private let awardsListener: AwardsListener
    private let awardManager: AwardManager
    private let settings: LocalSettings

    private weak var view: StickersView?
    private weak var coordinator: StickersCoordinatorProtocol?
    
    // MARK: - State

    // View model data for all user stickers
    private var myStickersData: [StickerData] = []
    
    // View model data for all gallery stickers
    private var galleryStickersData: [StickerData] = []

    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        goalsListener: GoalsListener,
        awardsListener: AwardsListener,
        awardManager: AwardManager,
        view: StickersView,
        coordinator: StickersCoordinatorProtocol,
        settings: LocalSettings
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.goalsListener = goalsListener
        self.awardsListener = awardsListener
        self.awardManager = awardManager
        self.view = view
        self.coordinator = coordinator
        self.settings = settings
    }

    /// Called when view finished initial loading.
    func onViewDidLoad() {
        setupView()
        
        // Subscribe to stamp listener in case stamps array ever changes
        stampsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            self?.loadViewData()
        })

        // Subscribe to goals listener in case stamps array ever changes
        goalsListener.startListening(onError: { error in
            fatalError("Unexpected error: \(error)")
        },
        onChange: { [weak self] stamps in
            self?.loadViewData()
        })

        // Subscribe to awards listener for when new award is given
        // (to update list of goals including badges)
        awardsListener.startListening(onChange: { [weak self] in
            self?.loadViewData()
        })
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
        loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onStickerTapped = { [weak self] stickerId in
            guard let sticker = self?.repository.stampBy(id: stickerId) else { return }
            self?.coordinator?.editSticker(sticker)
        }
        view?.onGalleryStickerTapped = { [weak self] stickerId in
            guard let gallerySticker = self?.repository.galleryStickerBy(id: stickerId) else { return }
            self?.copyFromGallery(gallerySticker)
        }
        view?.onNewStickerTapped = { [weak self] in
            self?.coordinator?.newSticker()
        }
        view?.onAddButtonTapped = { [weak self] in
            self?.coordinator?.newSticker()
        }
    }
   
    // Create sticker from the gallery one
    private func copyFromGallery(_ gallerySticker: GallerySticker) {
        let sticker = Stamp(
            name: gallerySticker.name.localized,
            label: gallerySticker.label,
            color: gallerySticker.color)
        
        do { try repository.save(stamp: sticker) }
        catch {}
    }
    
    private func loadViewData() {
        view?.updateTitle("stickers_tab_title".localized)

        let newMyStickersData =
            repository.allStamps().sorted(by: { $0.count > $1.count }).map({
                StickerData(
                    stampId: $0.id,
                    label: $0.label,
                    color: $0.color,
                    isUsed: false
                )
            })

        let newGalleryStickersData =
            repository.allGalleryStickers().map({
                StickerData(
                    stampId: $0.id,
                    label: $0.label,
                    color: $0.color,
                    isUsed: false
                )
            })

        var updated = false
        if myStickersData != newMyStickersData {
            myStickersData = newMyStickersData
            updated = true
        }
        
        if galleryStickersData != newGalleryStickersData {
            galleryStickersData = newGalleryStickersData
            updated = true
        }

        if updated {
            view?.loadData(
                stickers: myStickersData,
                gallery: galleryStickersData)
        }
    }
}
