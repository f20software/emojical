//
//  StickerDetailsDeleteButtonCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerDetailsDeleteButtonCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var footer: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var separator: UIView!

    /// User tapped on the Delete button
    var onDeleteTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Actions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        onDeleteTapped?()
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        footer.textColor = Theme.shared.colors.secondaryText
        footer.text = "delete_sticker_description".localized
        deleteButton.setTitle("delete_sticker_button".localized, for: .normal)
        separator.backgroundColor = Theme.shared.colors.separator

        updateFonts()
    }
    
    override func updateFonts() {
        footer.font = Theme.shared.fonts.footer
        deleteButton.titleLabel?.font = Theme.shared.fonts.boldButtons
    }
}
