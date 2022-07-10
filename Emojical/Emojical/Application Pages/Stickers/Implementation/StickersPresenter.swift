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
    private weak var coordinator: StickersCoordinatorProtocol?
    
    // MARK: - Lifecycle

    init(
        repository: DataRepository,
        stampsListener: StampsListener,
        view: StickersView,
        coordinator: StickersCoordinatorProtocol
    ) {
        self.repository = repository
        self.stampsListener = stampsListener
        self.view = view
        self.coordinator = coordinator
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
    }
    
    /// Called when view about to appear on the screen
    func onViewWillAppear() {
         // loadViewData()
    }
    
    // MARK: - Private helpers

    private func setupView() {
        view?.onStickerTapped = { [weak self] stickerId in
            guard let sticker = self?.repository.stickerBy(id: stickerId) else { return }
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
        guard repository.stickerByLabel(gallerySticker.label) == nil else {
            return
        }

        let sticker = Sticker(
            name: gallerySticker.name.localized,
            label: gallerySticker.label,
            color: gallerySticker.color)
        
        
        
        do { try repository.save(stamp: sticker) }
        catch {}
    }
    
    private func loadViewData() {
        view?.updateTitle("stickers_title".localized)

        let myStickersData =
            repository.allStamps().sorted(by: { $0.count > $1.count }).map({
                StickerData(
                    stampId: $0.id,
                    label: $0.label,
                    color: $0.color,
                    isUsed: false
                )
            })

        let galleryStickersData =
            myStickersData.count >= Specs.maxStickersToHideGallery ? [] :
            repository.allGalleryStickers().map({
                StickerData(
                    stampId: $0.id,
                    label: $0.label,
                    color: $0.color,
                    isUsed: false
                )
            })

        view?.loadData(
            stickers: myStickersData,
            gallery: galleryStickersData
        )
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Once user created `maxStickersToHideGallery` stickers we will hide Stickers Gallery
    static let maxStickersToHideGallery = 20
}
