//
//  AwardsRecapView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/24/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class AwardsRecapView : UIViewController, RecapView {

    // List of sections
    enum Section: String, CaseIterable {
        case reached = "Reached goals"
        case notReached = "Not reached goals"
    }

    // MARK: - UI Outlets
    
    // @IBOutlet weak var dragIndicator: UIView!
    // @IBOutlet weak var title: UILabel!
    @IBOutlet weak var awards: UICollectionView!

    // MARK: - DI

    var presenter: RecapPresenterProtocol!

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, AwardRecapData>!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - Public view interface

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
    
    // MARK: - Private helpers
    
    func setupViews() {
        // Collection view for stamps
        configureCollectionView()
        registerCells()
    }
    
    private func registerCells() {
        awards.register(
            UINib(nibName: "AwardRecapCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.award
        )
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
//        awards.alwaysBounceVertical = false
    }
    
    // Creates layout for the day column - vertical list of cells
    private func awardsRecapLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 0, bottom: 0, trailing: 0
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            ),
            subitems: [item]
        )

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)),
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

extension AwardsRecapView: UICollectionViewDelegate {
    
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
    
    /// Background plate corner radius
    static let plateCornerRadius: CGFloat = 8.0

    /// Shadow radius
    static let shadowRadius: CGFloat = 15.0
    
    /// Shadow opacity
    static let shadowOpacity: Float = 0.3
    
    /// Shadow offset
    static let shadowOffset = CGSize.zero

    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0

    /// Cell margin
    static let cellMargin: CGFloat = 16.0
}
