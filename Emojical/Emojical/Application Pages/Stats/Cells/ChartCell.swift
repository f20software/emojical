//
//  ChartCell.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class ChartCell: ThemeObservingCollectionCell {

    // MARK: - Outlets

    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet weak var leadMargin: NSLayoutConstraint!
    @IBOutlet weak var trailMargin: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!

    @IBOutlet weak var icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Public view interface

    func configure(for chart: ChartTypeDetails) {
        title.text = chart.title
        subTitle.text = chart.subTitle
        icon.image = chart.icon
    }

    // MARK: - Private helpers

    private func configureViews() {
        plate.layer.cornerRadius = Theme.main.specs.platesCornerRadius
        plate.backgroundColor = Theme.main.colors.secondaryBackground
        plate.clipsToBounds = true
        leadMargin.constant = Specs.margin
        topMargin.constant = Specs.margin
        trailMargin.constant = Specs.margin
        
        title.textColor = Theme.main.colors.text
        subTitle.textColor = Theme.main.colors.secondaryText
        updateFonts()
    }
    
    override func updateFonts() {
        title.font = Theme.main.fonts.listTitle
        subTitle.font = Theme.main.fonts.listBody
    }
}

fileprivate struct Specs {
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0
}
