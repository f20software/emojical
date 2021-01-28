//
//  StampSelectorView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StampSelectorView : UIView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var stamps: UICollectionView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dragIndicator: UIView!

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StampSelectorElement>!
    
    // MARK: - Callbacks
    
    /// Called when user tapped on the sticker
    var onStampTapped: ((Int64) -> Void)?

    /// Called when user tapped on + to create new sticker
    var onNewStickerTapped: (() -> Void)?

    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Public view interface

    func loadData(_ data: [StampSelectorElement]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StampSelectorElement>()
        snapshot.appendSections([0])
        
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        
        // Arrange stamps in row by [stampsPerRow]. If we have fewer than [stampsPerRow],
        // center them inside selector view.
        // Otherwise make width to [stampsPerRow] elements, and number of row to 2
        // Will have to improve when more then 10 stamps are supported
        let rows = ((data.count - 1) / Specs.stickersPerRow) + 1
        
        let cellSize = Specs.stickerSize
        let gap = Specs.stickerMargin
        
        heightConstraint.constant = (cellSize + gap) * CGFloat(rows) - gap
        
        if rows == 1 {
            widthConstraint.constant = (cellSize + gap) * CGFloat(data.count)
        } else {
            widthConstraint.constant = (cellSize + gap) * CGFloat(Specs.stickersPerRow)
        }
    }
    
    // MARK: - Private helpers
    
    private func setupViews() {
        // Background view
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = Specs.plateCornerRadius
        
        layer.shadowRadius = Specs.shadowRadius
        layer.shadowOpacity = Specs.shadowOpacity
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = Specs.shadowOffset
        
        dragIndicator.layer.cornerRadius = dragIndicator.bounds.height / 2
        dragIndicator.backgroundColor = UIColor.appTintColor
        dragIndicator.layer.opacity = 0.7
        dragIndicator.clipsToBounds = true

        // Collection view for stamps
        configureCollectionView()
        registerCells()
    }
    
    private func registerCells() {
        stamps.register(
            UINib(nibName: "DayStampCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.stamp
        )
        stamps.register(
            UINib(nibName: "NewStickerCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.newSticker
        )
    }

    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, StampSelectorElement>(
            collectionView: stamps,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        stamps.dataSource = dataSource
        stamps.delegate = self
        stamps.collectionViewLayout = stampsSelectorLayout()
        stamps.backgroundColor = UIColor.clear
        stamps.alwaysBounceHorizontal = false
        stamps.alwaysBounceVertical = false
    }
    
    // Creates layout for the day column - vertical list of cells
    private func stampsSelectorLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(Specs.stickerSize),
                heightDimension: .absolute(Specs.stickerSize)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(Specs.stickerSize)
            ),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(Specs.stickerMargin)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Specs.stickerMargin
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension StampSelectorView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let stampId = collectionView.cellForItem(at: indexPath)?.tag else {
            return
        }
        
        if stampId > 0 {
            onStampTapped?(Int64(stampId))
        } else {
            onNewStickerTapped?()
        }
    }
    
    private func cell(for path: IndexPath, model: StampSelectorElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        switch model {
        case .stamp(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.stamp, for: path
            ) as? DayStampCell else { return UICollectionViewCell() }
            
            cell.configure(for: data, sizeDelta: Specs.stickerSelectionGap * 2)
            return cell
            
        case .newStamp:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.newSticker, for: path
            ) as? NewStickerCell else { return UICollectionViewCell() }
            cell.configure(iconRatio: 0.9)
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {
        
        /// Stamp cell
        static let stamp = "DayStampCell"

        /// New sticker cell
        static let newSticker = "NewStickerCell"
    }
    
    /// Stamp cell size
    static let stickerSize: CGFloat = 55.0
    
    /// Stickers row size
    static let stickersPerRow = 5
    
    /// Margins between stickers
    static let stickerMargin: CGFloat = 3.0

    /// Gap between sticker and selection border
    static let stickerSelectionGap: CGFloat = 4.0

    /// Background plate corner radius
    static let plateCornerRadius: CGFloat = 8.0

    /// Shadow radius
    static let shadowRadius: CGFloat = 15.0
    
    /// Shadow opacity
    static let shadowOpacity: Float = 0.3
    
    /// Shadow offset
    static let shadowOffset = CGSize.zero
}
