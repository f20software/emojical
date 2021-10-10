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
    
    @IBOutlet weak var cellGapMargin: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var leadMargin: NSLayoutConstraint!
    @IBOutlet weak var trailMargin: NSLayoutConstraint!

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
        cellGapMargin.constant = Specs.cellGap
        topMargin.constant = Specs.contentInsets.top
        bottomMargin.constant = Specs.contentInsets.bottom
        leadMargin.constant = Specs.contentInsets.left
        trailMargin.constant = Specs.contentInsets.right
        
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
    
    /// Vertical gap between cells
    static let cellGap: CGFloat = 20.0
    
    /// Content insets inside cell background plate
    static let contentInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
}
