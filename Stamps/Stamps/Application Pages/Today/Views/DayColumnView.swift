//
//  DayColumnView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayColumnView : UIView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var column: UICollectionView!
    
    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, DayElement>!
    
    // MARK: - Callbacks
    
    // Called when user tapped on the first cell in the list (which is day header)
    var onDayTapped: (() -> Void)?

    // Called when user tapped on a stamp in the list
    var onStampTapped: ((Int64) -> Void)?

    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface

    func loadData(data: DayColumnData) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, DayElement>()
        snapshot.appendSections([0])
        
        snapshot.appendItems([.header(data.header)])
        snapshot.appendItems(data.stamps.map({ DayElement.stamp($0) }))
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    // MARK: - Private helpers
    
    private func setupViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func registerCells() {
        column.register(
            UINib(nibName: "DayHeaderCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.header
        )

        column.register(
            UINib(nibName: "DayStampCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.stamp
        )
    }

    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, DayElement>(
            collectionView: column,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        column.dataSource = dataSource
        column.delegate = self
        column.collectionViewLayout = dayColumnLayout()
        column.alwaysBounceVertical = false
        
        column.backgroundColor = UIColor.clear
    }
    
    // Creates layout for the day column - vertical list of cells
    private func dayColumnLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Specs.verticalPadding, leading: Specs.horizontalPadding,
            bottom: Specs.verticalPadding, trailing: Specs.horizontalPadding)
        section.interGroupSpacing = Specs.verticalPadding

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension DayColumnView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            onDayTapped?()
        } else {
            onDayTapped?()
            // guard let stampId = collectionView.cellForItem(at: indexPath)?.tag else { return }
            // onStampTapped?(Int64(stampId))
        }
    }
    
    private func cell(for path: IndexPath, model: DayElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        switch model {
        case .header(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.header, for: path
            ) as? DayHeaderCell else { return UICollectionViewCell() }
            cell.configure(for: data)
            return cell

        case .stamp(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.stamp, for: path
            ) as? DayStampCell else { return UICollectionViewCell() }
            cell.configure(for: data, insets: Specs.stampInsets)
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {
        
        /// Header cell
        static let header = "DayHeaderCell"
        
        /// Stamp cell
        static let stamp = "DayStampCell"
    }
    
    /// Actual stamp insets inside the stamp cell
    static let stampInsets = UIEdgeInsets(top: 10.0, left: 2.0, bottom: 0.0, right: 2.0)

    /// Horizontal padding from the edge of day column to the cell edge
    static let horizontalPadding: CGFloat = 3.0
    
    /// Vertical padding from the top and bottom of the day column
    static let verticalPadding: CGFloat = 0.0
}
