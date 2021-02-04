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

    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var limit: UITextField!
    @IBOutlet weak var limitExplanation1: UILabel!
    @IBOutlet weak var limitExplanation2: UILabel!

    @IBOutlet weak var stickersLabel: UILabel!
    @IBOutlet weak var stickers: UILabel!
    @IBOutlet weak var selectStickersButton: UIButton!

    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var direction: UISegmentedControl!

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var period: UISegmentedControl!

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
            label?.font = Theme.shared.fonts.formFieldCaption
            label?.textColor = Theme.shared.colors.secondaryText
        }
        for label in [limitExplanation1, limitExplanation2] {
            label?.font = Theme.shared.fonts.formFieldCaption
            label?.textColor = Theme.shared.colors.text
        }

        nameLabel.text = "name_label".localized
        name.backgroundColor = UIColor.systemGray6
        name.font = Theme.shared.fonts.listBody
        
        stickersLabel.text = "stickers_label".localized
        stickers.font = Theme.shared.fonts.listBody
        
        limitLabel.text = "goal_label".localized
        limitExplanation1.text = "get_x_or_more".localized.components(separatedBy: "|").first
        limitExplanation2.text = "get_x_or_more".localized.components(separatedBy: "|").last
        
        limit.backgroundColor = UIColor.systemGray6
        limit.font = Theme.shared.fonts.listBody
        
        periodLabel.text = "goal_period_label".localized
        period.setTitle("week".localized.capitalizingFirstLetter(), forSegmentAt: 0)
        period.setTitle("month".localized.capitalizingFirstLetter(), forSegmentAt: 1)

        directionLabel.text = "direction_label".localized
        direction.setTitle("positive".localized.capitalizingFirstLetter(), forSegmentAt: 0)
        direction.setTitle("negative".localized.capitalizingFirstLetter(), forSegmentAt: 1)
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
