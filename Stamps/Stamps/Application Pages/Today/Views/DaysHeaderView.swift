//
//  DaysHeaderView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/22/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DaysHeaderView : UIView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var days: UICollectionView!

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, DayHeaderData>!
    
    // MARK: - Callbacks
    
    // Called when user tapped on the first cell in the list (which is day header)
    var onDayTapped: ((Int) -> Void)?

    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface

    func loadData(data: [DayHeaderData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, DayHeaderData>()
        snapshot.appendSections([0])
        
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    // MARK: - Private helpers
    
    private func setupViews() {
        // Collection view for awards
        configureCollectionView()
        registerCells()
    }
    
    private func registerCells() {
        days.register(
            UINib(nibName: "DayHeaderCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.header
        )
    }

    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, DayHeaderData>(
            collectionView: days,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        days.dataSource = dataSource
        days.delegate = self
        days.collectionViewLayout = awardsLayout()
        days.backgroundColor = UIColor.clear
        days.alwaysBounceHorizontal = false
        days.alwaysBounceVertical = false
    }
    
    // Creates layout for the day column - vertical list of cells
    private func awardsLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/7),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Specs.headerMargin,
            bottom: 0, trailing: Specs.headerMargin)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension DaysHeaderView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onDayTapped?(indexPath.row)
    }

    private func cell(for path: IndexPath, model: DayHeaderData, collectionView: UICollectionView) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.header, for: path
        ) as? DayHeaderCell else { return UICollectionViewCell() }

        cell.configure(for: model)
        return cell
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {
        
        /// Day header cell
        static let header = "DayHeaderCell"
    }
    
    /// Half of the margin between day header views
    static let headerMargin: CGFloat = 3.0
}
