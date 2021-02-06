//
//  SwitchCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var switchText: UILabel!
    @IBOutlet weak var switchControl: UISwitch!

    /// Called after switch value changed
    var onValueChanged: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for text: String, value: Bool) {
        switchText.text = text
        switchControl.isOn = value
    }

    // MARK: - Actions
    
    @IBAction func valueChanged(_ sender: Any) {
        onValueChanged?(switchControl.isOn)
    }

    // MARK: - Private helpers

    private func configureViews() {
        switchText.font = Theme.main.fonts.listBody
        switchControl.onTintColor = Theme.main.colors.tint
        backgroundColor = Theme.main.colors.secondaryBackground
    }
}
