//
//  YearBoxView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

import UIKit

class StickersHeaderView: UICollectionReusableView {

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
        backgroundColor = .systemBackground
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: topAnchor, constant: Specs.margin),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Specs.margin)
        ])
        
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.darkGray
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 15.0
}

