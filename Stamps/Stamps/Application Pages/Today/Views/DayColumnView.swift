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
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StickerData>!

    // MARK: - Private references
    
    private var tapRecognizer: UITapGestureRecognizer?
    
    // MARK: - Callbacks
    
    // Called when user tapped on the first cell in the list (which is day header)
    var onDayTapped: (() -> Void)?

    // Called when user tapped on a stamp in the list - not used yet
    var onStampTapped: ((Int64) -> Void)?

    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface

    func loadData(data: [StickerData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StickerData>()
        snapshot.appendSections([0])
        
        // snapshot.appendItems([.header(data.header)])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    // MARK: - Private helpers
    
    private func setupViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func registerCells() {
        column.register(
            UINib(nibName: "DayStampCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.stamp
        )
    }

    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, StickerData>(
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
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        column.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        onDayTapped?()
    }
    
    // Creates layout for the day column - vertical list of cells
    private func dayColumnLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1.0)
            )
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(Specs.stickerMargin)
        group.contentInsets = NSDirectionalEdgeInsets(
            top: Specs.stickerMargin, leading: Specs.stickerMargin / 2, 
            bottom: 0, trailing: Specs.stickerMargin / 2)
        
        let section = NSCollectionLayoutSection(group: group)
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
    
    private func cell(for path: IndexPath, model: StickerData, collectionView: UICollectionView) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.stamp, for: path
        ) as? DayStampCell else { return UICollectionViewCell() }
        cell.configure(for: model, sizeDelta: 0)
        return cell
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {
        /// Stamp cell
        static let stamp = "DayStampCell"
    }
    
    /// Margin between each columns and rows of stickers
    static let stickerMargin: CGFloat = 10.0
}
