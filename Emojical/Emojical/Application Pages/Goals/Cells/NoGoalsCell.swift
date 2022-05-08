//
//  NoGoalsCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/11/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class NoGoalsCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!

    /// User tapped on the first button
    var onButtonATapped: (() -> Void)?

    /// User tapped on the second button
    var onButtonBTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: NoGoalsData) {
        instructions.text = data.instructions
        icon.image = data.icon
        
        buttonA.setAttributedTitle(
            NSAttributedString(
                string: data.buttonA,
                attributes: [
                    .font: Theme.main.fonts.boldButtons,
                    .foregroundColor: Theme.main.colors.tint
                ]), for: .normal
        )
        
        buttonB.setAttributedTitle(
            NSAttributedString(
                string: data.buttonB,
                attributes: [
                    .font: Theme.main.fonts.boldButtons,
                    .foregroundColor: Theme.main.colors.tint
                ]), for: .normal
        )
    }

    // MARK: - Actions
    
    @IBAction func buttonATapped(_ sender: Any) {
        onButtonATapped?()
    }

    @IBAction func buttonBTapped(_ sender: Any) {
        onButtonBTapped?()
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        instructions.font = Theme.main.fonts.listBody
        instructions.textColor = Theme.main.colors.secondaryText
    }
}
