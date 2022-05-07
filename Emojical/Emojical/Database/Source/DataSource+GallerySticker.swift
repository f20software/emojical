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
    
    /// Gallery sticker by a given Id
    func galleryStickerBy(id: Int64?) -> GallerySticker? {
        guard let id = id else { return nil }
        return storedGallerySticker(withId: id)?.toModel()
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
    
    func storedGallerySticker(withId id: Int64) -> StoredGallerySticker? {
        do {
            return try dbQueue.read { db -> StoredGallerySticker? in
                let request = StoredGallerySticker.filter(StoredGallerySticker.Columns.id == id)
                return try request.fetchOne(db)
            }
        }
        catch { }
        return nil
    }
}
