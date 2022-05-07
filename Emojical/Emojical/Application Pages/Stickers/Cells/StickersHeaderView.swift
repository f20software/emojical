//
//  StickersHeaderView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/6/22.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// This view is used to display section header for Stickers collection views
/// |----------------------------------------|
/// | --- Header Label --------------- -|
/// | --- Tltle Label ----- [ Button ]-|
/// |----------------------------------------|
class StickersHeaderView: UICollectionReusableView {

    private let titleLabel = UILabel()
    private let headerLabel = UILabel()
    private let button = UIButton(type: .system)

    /// User tapped on the goal
    var onButtonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(_ title: String, headerText: String?, buttonText: String?) {
        titleLabel.text = title.uppercased()
        headerLabel.text = headerText
        if buttonText != nil {
            button.setAttributedTitle(
                NSAttributedString(
                    string: buttonText!.uppercased(),
                    attributes: [.font: Theme.main.fonts.sectionHeaderTitle]),
                for: .normal)
        } else {
            button.isHidden = true
        }
    }
    
    func setupView() {
        backgroundColor = Theme.main.colors.background
        addSubview(titleLabel)
        addSubview(headerLabel)
        addSubview(button)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.numberOfLines = 0
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            headerLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -Specs.margin),
            headerLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -Specs.margin),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: Specs.margin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Specs.titleMargin),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -Specs.titleMargin)
        ])

        titleLabel.font = Theme.main.fonts.sectionHeaderTitle
        titleLabel.textColor = Theme.main.colors.sectionHeaderText
        headerLabel.font = Theme.main.fonts.listBody
        headerLabel.textColor = Theme.main.colors.secondaryText

        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
    }

    @objc func buttonTapped(sender: UIButton) {
        onButtonTapped?()
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 15.0

    /// Margin from title to the section content
    static let titleMargin: CGFloat = 5.0
}

