//
//  GoalStreaksHeaderView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 10/9/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// This view is used to display section header in Goal Stats chart - it includes three labels - the main section header,
/// and two separate column headers
class GoalStreaksHeaderView: UICollectionReusableView {

    //
    // | - Header ------------------ |
    // | - col1 Header - col2 Header |
    //
    private let header = UILabel()
    private let col1Header = UILabel()
    private let col2Header = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(
        headerText: String?,
        col1HeaderText: String?,
        col2HeaderText: String?
    ) {
        header.text = headerText
        col1Header.text = col1HeaderText
        col2Header.text = col2HeaderText
    }

    /// Hacky way to update single column 1 header, since it's used to display chart mode
    func updateCol1(text: String) {
        col1Header.text = text
    }
    
    func setupView() {
        backgroundColor = Theme.main.colors.background
        for l in [header, col1Header, col2Header] {
            addSubview(l)
            l.translatesAutoresizingMaskIntoConstraints = false
            l.adjustsFontForContentSizeCategory = true
            l.font = Theme.main.fonts.sectionHeaderTitle
            l.textColor = Theme.main.colors.sectionHeaderText
        }

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            header.topAnchor.constraint(equalTo: topAnchor, constant: Specs.topMargin),
            col1Header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            col2Header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            col1Header.trailingAnchor.constraint(equalTo: col2Header.leadingAnchor, constant: 0),
            col1Header.topAnchor.constraint(equalTo: col2Header.topAnchor, constant: 0),
            col1Header.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Specs.headersGap),
            col1Header.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Specs.bottomMargin),
            col2Header.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Specs.bottomMargin),
        ])
    }
}

// MARK: - Specs
fileprivate struct Specs {

    //
    // | - Header ------------------ |
    // | - col1 Header - col2 Header |
    //

    /// Top margin from the header label
    static let topMargin: CGFloat = 15.0
    
    /// Bottom margin from the column headers label
    static let bottomMargin: CGFloat = 5.0
    
    /// Margin between header and column headers
    static let headersGap: CGFloat = 5.0
}

