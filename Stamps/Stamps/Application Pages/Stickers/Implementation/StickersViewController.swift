//
//  StickersViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickersViewController: UIViewController, StickersView {
    
    // MARK: - Outlets
    
    @IBOutlet var collectionView: UICollectionView!

    // MARK: - DI

    var presenter: StickersPresenterProtocol!
    
    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StickersElement>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = StickersPresenter(
            repository: Storage.shared.repository,
            stampsListener: Storage.shared.stampsListener(),
            view: self)
        
        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - StickersView
    
    /// Load data
    func loadData(stickers: [Stamp], goals: [Goal]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StickersElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(stickers.map({ StickersElement.sticker($0.name) }))
        snapshot.appendSections([1])
        snapshot.appendItems(goals.map({ StickersElement.sticker($0.name) }))

        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    // MARK: - Actions
    
    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, StickersElement>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.collectionViewLayout = stickersLayout()
        collectionView.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        collectionView.register(
            UINib(nibName: "StickerCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.stickerCell
        )
        collectionView.register(
            UINib(nibName: "Goal2Cell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalCell
        )
    }

    // Creates layout for monthly stats - each month inside box cell
    private func stickersLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(100)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 20,
            bottom: 0, trailing: 20)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 0,
            bottom: 20, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension StickersViewController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: StickersElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        switch model {
        case .sticker(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.stickerCell, for: path
            ) as? StickerCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell

        case .goal(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.goalCell, for: path
            ) as? Goal2Cell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Cell identifiers
    struct Cells {
        
        /// Sticker cell identifier
        static let stickerCell = "StickerCell"

        /// Goal cell identifier
        static let goalCell = "GoalCell"
    }
}
