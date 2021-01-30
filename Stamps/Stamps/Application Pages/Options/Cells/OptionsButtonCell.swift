//
//  OptionsButtonCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class OptionsButtonCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var button: UIButton!

    /// User tapped on the Delete button
    var onButtonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: String) {
        button.setTitle(data, for: .normal)
    }

    // MARK: - Private helpers

    // MARK: - Actions
    
    @IBAction func buttonTapped(_ sender: Any) {
        onButtonTapped?()
    }

    private func configureViews() {
        button.titleLabel?.font = Theme.shared.fonts.buttons
        backgroundColor = Theme.shared.colors.secondaryBackround
    }
}
