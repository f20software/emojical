//
//  SwitchCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class TimeCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!

    /// Called after time picker value changed
    var onValueChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for text: String, time: Date) {
        timeLabel.text = text
        timePicker.date = time
    }

    // MARK: - Actions
    
    @IBAction func valueChanged(_ sender: Any) {
        onValueChanged?(timePicker.date)
    }

    // MARK: - Private helpers

    private func configureViews() {
        timeLabel.font = Theme.main.fonts.listBody
        timePicker.tintColor = Theme.main.colors.tint
        backgroundColor = Theme.main.colors.secondaryBackground
        selectionStyle = .none
    }
}
