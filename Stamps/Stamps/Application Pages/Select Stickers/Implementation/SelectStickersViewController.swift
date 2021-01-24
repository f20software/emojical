//
//  SelectStickersViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/23/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class SelectStickersViewController : UIViewController, SelectStickersView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var stickers: UICollectionView!

    // MARK: - DI

    var presenter: SelectStickersPresenterProtocol!

    // MARK: - State
    
    /// Diffable data source
    private var dataSource: UICollectionViewDiffableDataSource<Int, SelectStickerData>!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        registerCells()
        presenter.onViewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.onViewWillAppear()
    }
    
    // MARK: Goal View
    
    /// User tapped on sticker (select / deselect)
    var onStickerTapped: ((Int64) -> Void)?

    /// Loads stickers data
    func loadData(_ data: [SelectStickerData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SelectStickerData>()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {
        title = "Select Stickers"
    }
    
    private func registerCells() {
        stickers.register(
            UINib(nibName: "SelectStickerCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.sticker
        )
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, SelectStickerData>(
            collectionView: stickers,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        stickers.dataSource = dataSource
        stickers.delegate = self
        stickers.collectionViewLayout = selectStickersLayout()
        stickers.backgroundColor = UIColor.clear
        stickers.alwaysBounceHorizontal = false
    }
    
    // Creates layout for the collection of large awards cells (1/3 of width)
    private func selectStickersLayout() -> UICollectionViewCompositionalLayout {
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
            top: Specs.margin, leading: Specs.margin,
            bottom: Specs.margin, trailing: Specs.margin
        )

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension SelectStickersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectStickerCell else { return }
        onStickerTapped?(Int64(cell.tag))
    }
    
    private func cell(for path: IndexPath, model: SelectStickerData, collectionView: UICollectionView) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.sticker, for: path
        ) as? SelectStickerCell else { return UICollectionViewCell() }
        cell.configure(for: model)
        return cell
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {

        /// Sticker selection cell
        static let sticker = "SelectStickerCell"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0
}
