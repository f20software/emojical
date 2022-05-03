//
//  StoredGallerySticker.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/2/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit
import GRDB

struct StoredGallerySticker {
    // Prefer Int64 for auto-incremented database ids
    var id: Int64?
    var name: String
    var label: String
    var color: String // Hex representation like 01cd12
}

extension StoredGallerySticker : Hashable { }

// MARK: - Persistence

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension StoredGallerySticker: Codable, FetchableRecord, MutablePersistableRecord {

    static var databaseTableName = "stickers_gallery"
    
    // Define database columns
    enum Columns: String, ColumnExpression {
        case id
        case name
        case label
    }

    // Update a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Database access

// Define some useful player requests.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
extension StoredGallerySticker {
    static func orderedByName() -> QueryInterfaceRequest<StoredGallerySticker> {
        return StoredGallerySticker.all().order(Columns.name)
    }
}

// MARK: - Model conversion

extension StoredGallerySticker {
    func toModel() -> GallerySticker {
        return GallerySticker(
            id: id,
            name: name,
            label: label,
            color: UIColor(hex: color)
        )
    }
    
    init(sticker: GallerySticker) {
        self.id = sticker.id
        self.name = sticker.name
        self.label = sticker.label
        self.color = sticker.color.hex
    }
}
