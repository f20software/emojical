//
//  WeeklyAwardsView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/07/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class WeeklyAwardsView : UIView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var awards: UICollectionView!

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, GoalAwardData>!
    
    // MARK: - Callbacks
    
    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface

    func loadData(data: [GoalAwardData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, GoalAwardData>()
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
        awards.register(
            UINib(nibName: "TodayAwardCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.award
        )
    }

    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, GoalAwardData>(
            collectionView: awards,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        awards.dataSource = dataSource
        awards.delegate = self
        awards.collectionViewLayout = awardsLayout()
        awards.backgroundColor = UIColor.clear
        awards.alwaysBounceHorizontal = false
        awards.alwaysBounceVertical = false
    }
    
    // Creates layout for the day column - vertical list of cells
    private func awardsLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(Specs.awardSize),
                heightDimension: .absolute(Specs.awardSize)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(Specs.awardSize)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 5,
            bottom: 0, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension WeeklyAwardsView: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: GoalAwardData, collectionView: UICollectionView) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.award, for: path
        ) as? TodayAwardCell else { return UICollectionViewCell() }
        
        cell.configure(for: model)
        return cell
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {
        
        /// Stamp cell
        static let award = "TodayAwardCell"
    }
    
    /// Award cell size
    static let awardSize: CGFloat = 50.0
}
