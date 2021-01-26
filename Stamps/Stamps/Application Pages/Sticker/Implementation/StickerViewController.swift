//
//  StickerViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/24/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerViewController : UIViewController, StickerViewProtocol {

    // MARK: - UI Outlets
    
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    @IBOutlet var editBarButton: UIBarButtonItem!

    @IBOutlet weak var details: UICollectionView!

    // MARK: - DI

    var presenter: StickerPresenterProtocol!

    // MARK: - State
    
    /// Diffable data source
    private var dataSource: UICollectionViewDiffableDataSource<Int, StickerDetailsElement>!
    
    /// Details cell
    private weak var detailsEditView: StickerDetailsEditCell?

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
    
    /// User tapped on the Edit button
    var onEditTapped: (() -> Void)?

    /// User tapped on the Cancel button
    var onCancelTapped: (() -> Void)?

    /// User tapped on the Done button
    var onDoneTapped: (() -> Void)?

    /// User tapped on the Delete button
    var onDeleteTapped: (() -> Void)?

    /// User tapped on list of stickers to select
    var onSelectStickersTapped: (() -> Void)?

    /// Uer has changed any data
    var onStickerChanged: (() -> Void)?

    /// Set / reset editing mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        configureBarButtons(animated: animated)
    }

    /// When creating new sticker we want to bring emoji keyboard immediately
    func focusOnEmoji() {
        DispatchQueue.main.async {
            self.detailsEditView?.emoji.becomeFirstResponder()
        }
    }
    
    /// Set form title
    func updateTitle(_ text: String) {
        title = text
    }

    /// Set form title
    func updateIcon(_ sticker: Stamp) {
        guard let view = detailsEditView else { return }
        view.stickerIcon.color = sticker.color
        view.stickerIcon.text = sticker.label
        view.stickerIcon.setNeedsDisplay()
    }

    /// Loads Sticker data
    func loadStickerData(_ data: [StickerDetailsElement]) {

        // Reset old reference
        detailsEditView = nil
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, StickerDetailsElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    /// Update Goal data from the UI
    func update(to: inout Stamp) {
        guard let details = detailsEditView else { return }
        
        to.name = (details.name.text ?? to.name).trimmingCharacters(in: CharacterSet(charactersIn: " "))
        to.label = details.emoji.text ?? ""
        to.color = Theme.shared.colors.pallete[details.selectedColorIndex]
//        to.limit = Int.init(details.limit.text ?? "0") ?? 0
//        to.direction = Direction(rawValue: details.direction.selectedSegmentIndex) ?? .positive
//        to.period = Period(rawValue: details.period.selectedSegmentIndex) ?? .week
    }

    /// Dismisses view if it was presented modally
    func dismiss(from mode: PresentationMode) {
        switch mode {
        case .modal:
            dismiss(animated: true, completion: nil)
        case .push:
            navigationController?.popViewController(animated: true)
        }
    }

    /// Enable / disable saving data
    func enableDoneButton(_ enabled: Bool) {
        doneBarButton.isEnabled = enabled
    }

    // MARK: - Action
    
    @IBAction func editButtonTapped(_ sender: Any) {
        onEditTapped?()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        onCancelTapped?()
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        onDoneTapped?()
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureBarButtons(animated: false)
    }
    
    private func registerCells() {
        details.register(
            UINib(nibName: "StickerDetailsCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.details
        )
        details.register(
            UINib(nibName: "StickerDetailsEditCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.edit
        )
        details.register(
            UINib(nibName: "StickerDetailsDeleteButtonCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.delete
        )
    }

    private func configureBarButtons(animated: Bool) {
        if isEditing {
            navigationItem.leftBarButtonItem = cancelBarButton
            navigationItem.setRightBarButtonItems([doneBarButton], animated: animated)
        }
        else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.setRightBarButtonItems([editBarButton], animated: animated)
        }
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, StickerDetailsElement>(
            collectionView: details,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        details.dataSource = dataSource
        details.delegate = self
        details.collectionViewLayout = stickerDetailsLayout()
        details.backgroundColor = UIColor.clear
        details.alwaysBounceHorizontal = false
    }
    
    // Creates layout for the collection of large awards cells (1/3 of width)
    private func stickerDetailsLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
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

extension StickerViewController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: StickerDetailsElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        switch model {
        case .view(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.details, for: path
            ) as? StickerDetailsCell else { return UICollectionViewCell() }
            cell.configure(for: data)
            return cell
            
        case .edit(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.edit, for: path
            ) as? StickerDetailsEditCell else { return UICollectionViewCell() }
            
            cell.setColors(Theme.shared.colors.pallete)
            cell.configure(for: data)
            cell.onValueChanged = { [weak self] in
                // WTF???? - for some reason previous reference to detailsEditView will
                // point to something else...
                self?.detailsEditView = cell
                self?.onStickerChanged?()
            }
            cell.onColorSelected = { [weak self] index in
                self?.onStickerChanged?()
            }
            detailsEditView = cell
            return cell
            
        case .deleteButton:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.delete, for: path
            ) as? StickerDetailsDeleteButtonCell else { return UICollectionViewCell() }
            cell.onDeleteTapped = { [weak self] in
                self?.onDeleteTapped?()
            }
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {

        /// Sticker details cell
        static let details = "StickerDetailsCell"

        /// Sticker editing cell
        static let edit = "StickerDetailsEditCell"

        /// Sticker editing delete button cell
        static let delete = "StickerDetailsDeleteButtonCell"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0
}
