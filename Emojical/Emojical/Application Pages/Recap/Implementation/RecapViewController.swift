//
//  AwardsRecapViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class RecapViewController : UIViewController, RecapView {

    // List of sections
    enum Section: String, CaseIterable {
        case reached = "reached_goals_title"
        case notReached = "not_reached_goals_title"
    }

    // MARK: - UI Outlets
    
    @IBOutlet weak var awards: UICollectionView!

    // MARK: - DI

    var presenter: RecapPresenterProtocol!

    // MARK: - State
    
    /// Diffable data source
    private var dataSource: UICollectionViewDiffableDataSource<Int, AwardRecapData>!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        registerCells()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.onViewWillAppear()
    }
    
    // MARK: - RecapView
    
    /// User tapped on the award
    var onAwardTapped: ((IndexPath) -> Void)?

    /// Loads awards recap data
    func loadRecapData(data: [AwardRecapData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AwardRecapData>()
        let reached = data.filter({
            switch $0.progress {
            case .award(let awardData):
                return awardData.reached
            default:
                return false
            }
        })
        let notReached = data.filter({
            switch $0.progress {
            case .goal(_):
                return true
            case .award(let awardData):
                return !awardData.reached
            }
        })
        
        // TODO: Fix this
        // Adding first section always, otherwise section header
        // will be screwed up
        snapshot.appendSections([0])
        if reached.count > 0 {
            snapshot.appendItems(reached)
        }
        
        if notReached.count > 0 {
            snapshot.appendSections([1])
            snapshot.appendItems(notReached)
        }
        
        title = "weekly_recap_title".localized
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    /// Highlight selected award
    func highlightAward(at indexPath: IndexPath, highlight: Bool) {
        guard let cell = awards.cellForItem(at: indexPath) as? AwardRecapCell else {
            return
        }
        cell.isHighlighted = highlight
    }
    
    // MARK: - Private helpers
    
    private func registerCells() {
        awards.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: Specs.Cells.header,
            withReuseIdentifier: Specs.Cells.header
        )
        awards.register(
            UINib(nibName: "AwardRecapCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.award
        )
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, AwardRecapData>(
            collectionView: awards,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView, kind, indexPath) -> UICollectionReusableView? in
            self?.header(for: indexPath, kind: kind, collectionView: collectionView)
        }

        awards.dataSource = dataSource
        awards.delegate = self
        awards.collectionViewLayout = awardsRecapLayout()
        awards.backgroundColor = UIColor.clear
        awards.alwaysBounceHorizontal = false
    }
    
    // Creates layout for the collection of large awards cells (1/3 of width)
    private func awardsRecapLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.33),
                heightDimension: .fractionalWidth(0.33)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 0,
            bottom: Specs.margin, trailing: Specs.margin
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.33)
            ),
            subitems: [item]
        )

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(34)
            ),
            elementKind: Specs.Cells.header,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Specs.margin,
            bottom: 0, trailing: 0
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - RecapView implementation

extension RecapViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onAwardTapped?(indexPath)
    }
    
    private func cell(for path: IndexPath, model: AwardRecapData, collectionView: UICollectionView) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.award, for: path
        ) as? AwardRecapCell else { return UICollectionViewCell() }
        
        cell.configure(for: model)
        return cell
    }

    private func header(for path: IndexPath, kind: String, collectionView: UICollectionView) ->
        UICollectionReusableView? {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Specs.Cells.header,
            for: path) as? CollectionHeaderView else { return UICollectionReusableView() }

        header.configure(Section.allCases[path.section].rawValue.localized)
        return header
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {
        /// Award cell
        static let award = "AwardRecapCell"

        /// Custom supplementary header identifier and kind
        static let header = "stickers-header-element"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0
}
