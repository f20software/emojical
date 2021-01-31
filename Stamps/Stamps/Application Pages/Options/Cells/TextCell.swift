//
//  TextCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for text: String?, value: String?) {
        textLabel?.text = text
        detailTextLabel?.text = value
    }

    // MARK: - Private helpers

    private func configureViews() {
        textLabel?.font = Theme.shared.fonts.listBody
        detailTextLabel?.font = Theme.shared.fonts.listBody
        backgroundColor = Theme.shared.colors.secondaryBackground
    }
}
