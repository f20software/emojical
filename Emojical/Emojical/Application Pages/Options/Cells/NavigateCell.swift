//
//  NavigateCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NavigateCell: UITableViewCell {

    /// User selected cell
    var onSelected: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: String) {
        textLabel?.text  = data
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        textLabel?.font = Theme.main.fonts.listBody
        backgroundColor = Theme.main.colors.secondaryBackground
    }
}
