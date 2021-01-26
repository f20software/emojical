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
    private var dataSource: UICollectionViewDiffableDataSource<Int, SelectStickerElement>!
    
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

    /// User tapped on create new sticker
    var onNewStickerTapped: (() -> Void)?

    /// Loads stickers data
    func loadData(_ data: [SelectStickerElement]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SelectStickerElement>()
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
            UINib(nibName: "SelectStickerCell2", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.sticker
        )
        stickers.register(
            UINib(nibName: "NewStickerCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.newSticker
        )
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, SelectStickerElement>(
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
                widthDimension: .fractionalWidth(0.20),
                heightDimension: .fractionalWidth(0.20)
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
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectStickerCell {
            onStickerTapped?(Int64(cell.tag))
        } else if (collectionView.cellForItem(at: indexPath) as? NewStickerCell) != nil {
            onNewStickerTapped?()
        }
    }
    
    private func cell(for path: IndexPath, model: SelectStickerElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        switch model {
        case .sticker(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.sticker, for: path
            ) as? SelectStickerCell else { return UICollectionViewCell() }
            cell.configure(for: data)
            return cell

        case .newSticker:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.newSticker, for: path
            ) as? NewStickerCell else { return UICollectionViewCell() }
            return cell

        }
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {

        /// Sticker selection cell
        static let sticker = "SelectStickerCell"

        /// New sticker selection cell
        static let newSticker = "NewStickerCell"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0
}
