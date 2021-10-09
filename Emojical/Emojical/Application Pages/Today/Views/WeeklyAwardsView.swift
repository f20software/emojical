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
    
    /// Diffable data source
    private var dataSource: UICollectionViewDiffableDataSource<Int, TodayAwardElement>!
    
    /// Is dataSource empty? Different layout will be generated if it's empty
    private var isDataSourceEmpty: Bool = false
    
    // MARK: - Callbacks
    
    // Called when user tapped on the award cell
    var onAwardTapped: ((Int) -> Void)?

    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface

    func loadData(_ data: [GoalOrAwardIconData]) {
        var empty = isDataSourceEmpty
        var snapshot = NSDiffableDataSourceSnapshot<Int, TodayAwardElement>()
        snapshot.appendSections([0])
        
        if data.count > 0 {
            snapshot.appendItems(data.map({ TodayAwardElement.award($0) }))
            empty = false
        } else {
            snapshot.appendItems([.noAwards("no_goals_reahed_week".localized)])
            empty = true
        }
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)

        // If emptiness of the dataSource has changed - need to re-create layout
        if empty != isDataSourceEmpty {
            isDataSourceEmpty = empty
            awards.collectionViewLayout = awardsLayout(empty: empty)
        }
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
        awards.register(
            UINib(nibName: "NoAwardsCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.noAwards
        )
    }

    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, TodayAwardElement>(
            collectionView: awards,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        awards.dataSource = dataSource
        awards.delegate = self
        awards.collectionViewLayout = awardsLayout(empty: isDataSourceEmpty)
        awards.backgroundColor = UIColor.clear
        awards.alwaysBounceHorizontal = false
        awards.alwaysBounceVertical = false
    }
    
    // Creates layout for the day column - vertical list of cells
    private func awardsLayout(empty: Bool) -> UICollectionViewCompositionalLayout {
        // When dataSource is empty - we just need to display one cell with full width
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: empty ? .fractionalWidth(1.0) : .absolute(Specs.awardSize),
                heightDimension: .absolute(Specs.awardSize)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: Specs.awardMargin, leading: Specs.awardMargin,
            bottom: Specs.awardMargin, trailing: Specs.awardMargin)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: empty ? .fractionalWidth(1.0) : .absolute(Specs.awardSize),
                heightDimension: .absolute(Specs.awardSize)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Specs.awardsLeadingMargin,
            bottom: 0, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension WeeklyAwardsView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onAwardTapped?(indexPath.row)
    }

    private func cell(for path: IndexPath, model: TodayAwardElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        switch  model {
        case .award(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.award, for: path
            ) as? TodayAwardCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell
            
        case .noAwards(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.noAwards, for: path
            ) as? NoAwardsCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {
        
        /// Award cell
        static let award = "TodayAwardCell"
        
        /// No awards cell
        static let noAwards = "NoAwardsCell"
    }
    
    /// Award cell size
    static let awardSize: CGFloat = 55.0
    
    /// Margin around award icons
    static let awardMargin: CGFloat = 3.0
    
    /// Margin before first award icon
    static let awardsLeadingMargin: CGFloat = 16.0
    
    /// Margin from the left/right of the award strip
    static let awardStripHorizontalMargin: CGFloat = 5.0
}
