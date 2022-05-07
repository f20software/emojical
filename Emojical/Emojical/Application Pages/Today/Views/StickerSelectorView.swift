//
//  StickerSelectorView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerSelectorView : ThemeObservingView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var stamps: UICollectionView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dragIndicator: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StickerSelectorElement>!
    private var stickerCount = 0
    
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

    func loadData(_ data: StickerSelectorData) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StickerSelectorElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(data.stickers)

        let oldStickerCount = stickerCount
        stickerCount = data.stickers.count
        // Add [+] icon if we have less then full one row of stickers
        if stickerCount < Specs.stickersPerRow {
            snapshot.appendItems([.newStamp])
            stickerCount += 1
        }
        
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        
        // Arrange stamps in row by [stampsPerRow]. If we have fewer than [stampsPerRow],
        // center them inside selector view.
        // Otherwise make
        // width = [stampsPerRow] elements
        // number of row = maxStickerRow
        // and allow for horizontal scrolling

        var numberOfRows = (stickerCount - 1) / Specs.stickersPerRow + 1
        let numberOfColumns = min(stickerCount, Specs.stickersPerRow)
        var needHorizontalScroll = false
        if numberOfRows > Specs.maxStickerRows {
            numberOfRows = Specs.maxStickerRows
            needHorizontalScroll = true
        }
        
        widthConstraint.constant =
            ((Specs.stickerSize + Specs.stickerMargin) * CGFloat(numberOfColumns)) - Specs.stickerMargin
        heightConstraint.constant =
            ((Specs.stickerSize + Specs.stickerMargin) * CGFloat(numberOfRows)) - Specs.stickerMargin
        
        if needHorizontalScroll == false {
            // alignScrollViewCenterConstraint.constant = 0
        } else {
            // alignScrollViewCenterConstraint.constant = Specs.stickerSize / 4
            widthConstraint.constant += Specs.stickerSize / 2
        }
        
        updateCollectionViewLayout()
        if oldStickerCount != stickerCount {
            stamps.setContentOffset(.zero, animated: false)
        }
        
        instructionsLabel.text = "select_stickers_for_day".localized(data.selectedDay)
    }
    
    // MARK: - Private helpers
    
    private func setupViews() {
        // Background view
        backgroundColor = Theme.main.colors.secondaryBackground
        layer.cornerRadius = Theme.main.specs.platesCornerRadius
        layer.shadowRadius = Specs.shadowRadius
        layer.shadowOpacity = Specs.shadowOpacity
        layer.shadowColor = Theme.main.colors.shadow.cgColor
        layer.shadowOffset = Specs.shadowOffset
        dragIndicator.layer.cornerRadius = dragIndicator.bounds.height / 2
        dragIndicator.layer.opacity = 0.8
        dragIndicator.clipsToBounds = true
        dragIndicator.backgroundColor = Theme.main.colors.tint

        instructionsLabel.text = "select_stickers_for_day".localized("")
        instructionsLabel.font = Theme.main.fonts.footer
        instructionsLabel.textColor = Theme.main.colors.secondaryText
        
        // Collection view for stamps
        configureCollectionView()
        registerCells()
    }
    
    override func updateColors() {
        layer.shadowColor = Theme.main.colors.shadow.cgColor
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
        self.dataSource = UICollectionViewDiffableDataSource<Int, StickerSelectorElement>(
            collectionView: stamps,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        stamps.dataSource = dataSource
        stamps.delegate = self
        updateCollectionViewLayout()

        stamps.backgroundColor = UIColor.clear
        stamps.showsHorizontalScrollIndicator = false
        stamps.showsVerticalScrollIndicator = false
        stamps.alwaysBounceHorizontal = false
        stamps.alwaysBounceVertical = false
    }
    
    private func updateCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Specs.stickerSize, height: Specs.stickerSize)
        layout.minimumInteritemSpacing = Specs.stickerMargin
        layout.minimumLineSpacing = Specs.stickerMargin
        layout.scrollDirection = stickerCount > (Specs.stickersPerRow * Specs.maxStickerRows) ? .horizontal : .vertical
        stamps.collectionViewLayout = layout
    }
}

extension StickerSelectorView: UICollectionViewDelegate {
    
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
    
    private func cell(for path: IndexPath, model: StickerSelectorElement, collectionView: UICollectionView) -> UICollectionViewCell? {
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
    
    /// Stickers row size
    static let maxStickerRows = 2

    /// Margins between stickers
    static let stickerMargin: CGFloat = 3.0

    /// Gap between sticker and selection border
    static let stickerSelectionGap: CGFloat = 4.0

    /// Shadow radius
    static let shadowRadius: CGFloat = 15.0
    
    /// Shadow opacity
    static let shadowOpacity: Float = 0.3
    
    /// Shadow offset
    static let shadowOffset = CGSize.zero
}
