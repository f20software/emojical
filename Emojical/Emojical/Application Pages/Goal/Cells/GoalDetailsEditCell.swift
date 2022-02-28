//
//  GoalDetailsEditCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalDetailsEditCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var separator1: UIView!

    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var limit: UITextField!
    @IBOutlet weak var limitExplanation1: UILabel!
    @IBOutlet weak var limitExplanation2: UILabel!
    @IBOutlet weak var separator2: UIView!

    @IBOutlet weak var stickersLabel: UILabel!
    @IBOutlet weak var stickers: UILabel!
    @IBOutlet weak var selectStickersButton: UIButton!
    @IBOutlet weak var separator3: UIView!

    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var direction: ECSegmentedControl!
    @IBOutlet weak var separator4: UIView!

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var period: ECSegmentedControl!
    @IBOutlet weak var separator5: UIView!

    /// User changed any value
    var onValueChanged: (() -> Void)?

    /// User tapped on list of stickers
    var onSelectStickersTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalEditData) {
        name.text = data.goal.name
        limit.text = "\(data.goal.limit)"
        
        let stickersText = data.stickers.joined(separator: ", ")
        if stickersText.lengthOfBytes(using: .utf8) > 0 {
            stickers.text = stickersText
        } else {
            stickers.text = "select_stickers_instructions".localized
        }
        direction.selectedSegmentIndex = data.goal.direction.rawValue
        period.selectedSegmentIndex = data.goal.period.rawValue
        directionChanged(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Actions
    
    @IBAction func selectStickersButtonTapped(_ sender: Any) {
        onSelectStickersTapped?()
    }

    @IBAction func directionChanged(_ sender: Any) {
        let positive = direction.selectedSegmentIndex == 0
        limitLabel.text = positive ?
            "goal_label".localized :
            "limit_label".localized
        
        limitExplanation2.text = positive ?
            "get_x_or_more".localized.components(separatedBy: "|").last :
            "get_x_or_fewer".localized.components(separatedBy: "|").last
        
        onValueChanged?()
    }
    
    @IBAction func periodChanged(_ sender: Any) {
        onValueChanged?()
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        
        for label in [nameLabel, limitLabel, stickersLabel, directionLabel, periodLabel] {
            label?.font = Theme.main.fonts.formFieldCaption
            label?.textColor = Theme.main.colors.secondaryText
        }
        for label in [limitExplanation1, limitExplanation2] {
            label?.font = Theme.main.fonts.formFieldCaption
            label?.textColor = Theme.main.colors.text
        }

        nameLabel.text = "name_label".localized
        name.placeholder = "goal_name_placeholder".localized
        name.backgroundColor = Theme.main.colors.secondaryBackground
        name.font = Theme.main.fonts.listBody
        separator1.backgroundColor = Theme.main.colors.separator
        
        stickersLabel.text = "stickers_label".localized
        stickers.font = Theme.main.fonts.listBody
        separator2.backgroundColor = Theme.main.colors.separator
        
        limitLabel.text = "goal_label".localized
        limitExplanation1.text = "get_x_or_more".localized.components(separatedBy: "|").first
        limitExplanation2.text = "get_x_or_more".localized.components(separatedBy: "|").last
        
        limit.backgroundColor = Theme.main.colors.secondaryBackground
        limit.font = Theme.main.fonts.listBody
        separator3.backgroundColor = Theme.main.colors.separator
        
        periodLabel.text = "goal_period_label".localized
        period.buttonTitleColor = Theme.main.colors.secondaryText
        period.buttonSelectedTitleColor = Theme.main.colors.background
        period.buttonFont = Theme.main.fonts.sectionHeaderTitle
        period.buttonColors = [Theme.main.colors.tint]
        period.setTitles(to: [
            "week".localized.capitalizingFirstLetter(),
            "month".localized.capitalizingFirstLetter(),
            "total".localized.capitalizingFirstLetter()
        ])
        separator4.backgroundColor = Theme.main.colors.separator

        directionLabel.text = "direction_label".localized
        direction.buttonTitleColor = Theme.main.colors.secondaryText
        direction.buttonSelectedTitleColor = Theme.main.colors.background
        direction.buttonFont = Theme.main.fonts.sectionHeaderTitle
        direction.buttonColors = [Theme.main.colors.tint]
        direction.setTitles(to: [
            "positive".localized.capitalizingFirstLetter(),
            "negative".localized.capitalizingFirstLetter()
        ])
        separator5.backgroundColor = Theme.main.colors.separator
    }
    
    @IBAction func textChanged(_ sender: Any) {
        onValueChanged?()
    }

    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: stickers)
        if stickers.bounds.contains(loc) {
            onSelectStickersTapped?()
        }
    }
}
