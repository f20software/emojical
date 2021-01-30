//
//  StickerDetailsDeleteButtonCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerDetailsDeleteButtonCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var footer: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

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
        footer.font = Theme.shared.fonts.footer
        footer.textColor = Theme.shared.colors.secondaryText
        footer.text = "If you delete the sticker, all previous usage of that sticker would remain unchanged."
        
        deleteButton.setTitle("Delete Sticker", for: .normal)
        deleteButton.titleLabel?.font = Theme.shared.fonts.boldButtons
    }
}
