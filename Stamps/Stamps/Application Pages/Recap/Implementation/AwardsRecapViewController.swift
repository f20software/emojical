//
//  AwardsRecapView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class AwardsRecapViewController : UIViewController {

    // List of sections
    enum Section: String, CaseIterable {
        case reached = "Reached goals"
        case notReached = "Not reached goals"
    }

    // MARK: - UI Outlets
    
    @IBOutlet weak var awards: UICollectionView!

    // MARK: - DI

    var presenter: RecapPresenterProtocol!

    // MARK: - State
    
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
    
    // MARK: - Private helpers
    
    private func registerCells() {
        awards.register(
            StickersHeaderView.self,
            forSupplementaryViewOfKind: Specs.Cells.header,
            withReuseIdentifier: Specs.Cells.header
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
        // awards.backgroundColor = UIColor.green
        // awards.alwaysBounceVertical = false
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

extension AwardsRecapViewController: RecapView {

    func loadRecapData(data: [AwardRecapData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AwardRecapData>()
        let reached = data.filter({ $0.progress.isReached == true })
        let notReached = data.filter({ $0.progress.isReached == false })
        
        if reached.count > 0 {
            snapshot.appendSections([0])
            snapshot.appendItems(reached)
        }
        
        if notReached.count > 0 {
            snapshot.appendSections([1])
            snapshot.appendItems(notReached)
        }
        
        title = "Weekly recap"
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension AwardsRecapViewController: UICollectionViewDelegate {
    
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
            for: path) as? StickersHeaderView else { return UICollectionReusableView() }

        header.configure(Section.allCases[path.section].rawValue)
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
