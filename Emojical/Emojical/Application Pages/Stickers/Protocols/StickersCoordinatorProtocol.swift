//
//  StickersCoordinatorProtocol.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StickersCoordinatorProtocol: AnyObject {

    /// Push to edit sticker form
    func editSticker(_ sticker: Sticker)

    /// Shows modal form to create new sticker
    func newSticker()
}
