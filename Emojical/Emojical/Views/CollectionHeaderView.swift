//
//  CollectionHeaderView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/6/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// This view is used to display section header for Stickers/Goals, Recap and Examples collection views
class CollectionHeaderView: UICollectionReusableView {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(_ text: String) {
        label.text = text.uppercased()
    }
    
    func setupView() {
        backgroundColor = Theme.main.colors.background
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: topAnchor, constant: Specs.margin),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Specs.margin)
        ])

        label.font = Theme.main.fonts.sectionHeaderTitle
        label.textColor = Theme.main.colors.sectionHeaderText
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 15.0
}

