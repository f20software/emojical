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

    @IBOutlet weak var footer: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    /// User tapped on the Delete button
    var onDeleteTapped: (() -> Void)?

    /// User changed any value
    var onValueChanged: (() -> Void)?

    /// User tapped on list of stickers
    var onSelectStickersTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for data: GoalEditData) {
        name.text = data.goal.name
        limit.text = "\(data.goal.limit)"
        stickers.text = data.stickers.joined(separator: ", ")
        direction.selectedSegmentIndex = data.goal.direction.rawValue
        period.selectedSegmentIndex = data.goal.period.rawValue
        directionChanged(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Actions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        onDeleteTapped?()
    }
    
    @IBAction func selectStickersButtonTapped(_ sender: Any) {
        onSelectStickersTapped?()
    }

    @IBAction func directionChanged(_ sender: Any) {
        let positive = direction.selectedSegmentIndex == 0
        limitLabel.text = positive ? "Goal:" : "Limit:"
        limitExplanation2.text = positive ? "or more" : "or fewer"
    }
    
    // MARK: - Private helpers

    private func configureViews() {
        plate.backgroundColor = UIColor.clear
        
        let labels: [UILabel] = [nameLabel, limitLabel, stickersLabel, directionLabel, periodLabel, limitExplanation1, limitExplanation2]
        for label in labels {
            label.font = Theme.shared.fonts.formFieldCaption
            label.textColor = Theme.shared.colors.secondaryText
        }

        nameLabel.text = "Name:"
        name.backgroundColor = UIColor.systemGray6
        name.font = Theme.shared.fonts.listBody
        
        stickersLabel.text = "Stickers:"
        stickers.font = Theme.shared.fonts.listBody
        
        limitLabel.text = "Goal:"
        limitExplanation1.text = "get"
        limitExplanation2.text = "or more"
        
        limit.backgroundColor = UIColor.systemGray6
        limit.font = Theme.shared.fonts.listBody
        
        periodLabel.text = "Goal Period:"
        directionLabel.text = "Direction:"
        
        footer.font = Theme.shared.fonts.footer
        footer.textColor = Theme.shared.colors.secondaryText
        footer.text = "If you update or delete the goal, all previously earned awards will remain unchanged."
        deleteButton.titleLabel?.font = Theme.shared.fonts.listBody

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: name)
    }

    @objc func textDidChange(sender: NSNotification) {
        onValueChanged?()
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Background corner radius
    static let cornerRadius: CGFloat = 8.0

    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 4.0
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 40.0
}

