//
//  ButtonCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {

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

    // MARK: - Actions
    
    @IBAction func buttonTapped(_ sender: Any) {
        onButtonTapped?()
    }

    // MARK: - Private helpers

    private func configureViews() {
        button.titleLabel?.font = Theme.main.fonts.buttons
        backgroundColor = Theme.main.colors.secondaryBackground
    }
}
