//
//  GoalViewController2.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/18/21.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalViewController2 : UIViewController, GoalView {

    // MARK: - UI Outlets
    
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    @IBOutlet var editBarButton: UIBarButtonItem!

    @IBOutlet weak var details: UICollectionView!

    // MARK: - DI

    var presenter: GoalPresenterProtocol!

    // MARK: - State
    
    /// Diffable data source
    private var dataSource: UICollectionViewDiffableDataSource<Int, GoalDetailsElement>!
    
    /// Details cell
    private weak var detailsEditView: GoalDetailsEditCell?

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

    /// Set / reset editing mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        configureBarButtons(animated: animated)
    }

    /// Loads Goal data
    func loadGoalDetails(_ data: GoalDetailsElement) {

        // Reset old reference
        detailsEditView = nil
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, GoalDetailsElement>()
        snapshot.appendSections([0])
        snapshot.appendItems([data])
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        
        switch data {
        case .view(let viewData):
            title = viewData.title
        case .edit(let viewData):
            title = viewData.goal.name
        }
    }
    
    /// Update Goal data from the UI
    func update(to: inout Goal) {
        guard let details = detailsEditView else { return }
        
        to.name = details.name.text ?? to.name
        to.limit = Int.init(details.limit.text ?? "1") ?? 1
        to.direction = Direction(rawValue: details.direction.selectedSegmentIndex) ?? .positive
        to.period = Period(rawValue: details.period.selectedSegmentIndex) ?? .week
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
            UINib(nibName: "GoalDetailsCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.details
        )
        details.register(
            UINib(nibName: "GoalDetailsEditCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.edit
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
        dataSource = UICollectionViewDiffableDataSource<Int, GoalDetailsElement>(
            collectionView: details,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        details.dataSource = dataSource
        details.delegate = self
        details.collectionViewLayout = goalDetailsLayout()
        details.backgroundColor = UIColor.clear
        details.alwaysBounceHorizontal = false
        // awards.backgroundColor = UIColor.green
        // awards.alwaysBounceVertical = false
    }
    
    // Creates layout for the collection of large awards cells (1/3 of width)
    private func goalDetailsLayout() -> UICollectionViewCompositionalLayout {
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

extension GoalViewController2: UICollectionViewDelegate {
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let editView = detailsEditView else { return }
//
//        editView.name.becomeFirstResponder()
//    }
    
    private func cell(for path: IndexPath, model: GoalDetailsElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        switch model {
        case .view(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.details, for: path
            ) as? GoalDetailsCell else { return UICollectionViewCell() }
            cell.configure(for: data)
            cell.onIconTapped = { () in
                cell.toggleState()
            }
            return cell
            
        case .edit(let data):
            detailsEditView = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.edit, for: path
            ) as? GoalDetailsEditCell
            
            guard let cell = detailsEditView else { return UICollectionViewCell() }
            cell.configure(for: data)
            cell.onDeleteTapped = { [weak self] in
                self?.onDeleteTapped?()
            }
            cell.onValueChanged = { [weak self] in
                self?.title = self?.detailsEditView?.name.text
            }
            cell.onSelectStickersTapped = { [weak self] in
                self?.onSelectStickersTapped?()
            }
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Cell identifiers
    struct Cells {

        /// Goal details cell
        static let details = "GoalDetailsCell"

        /// Goal editing cell
        static let edit = "GoalDetailsEditCell"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0
}
