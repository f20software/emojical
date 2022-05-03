//
//  DataSource+GalleryStickers.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/2/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//
import Foundation
import GRDB

// MARK: - Gallery Stickers Helper Methods
extension DataSource {

    /// All gallery stickers
    func allGalleryStickers() -> [GallerySticker] {
        allStoredGalleryStickers().map { $0.toModel() }
    }
    
    // MARK: - Private helpers
    
    func allStoredGalleryStickers() -> [StoredGallerySticker] {
        do {
            return try dbQueue.read { db -> [StoredGallerySticker] in
                let request = StoredGallerySticker.all()
                return try request.fetchAll(db)
            }
        }
        catch { }
        return []
    }
}
