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

    /// Set / reset editing mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        configureBarButtons(animated: animated)
    }

    /// Loads Goal data
    func loadGoal(data: [GoalDetailsElement]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, GoalDetailsElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    /// Dismisses view if it was presented modally
    func dismiss() {
        dismiss(animated: true, completion: nil)
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
//        item.contentInsets = NSDirectionalEdgeInsets(
//            top: 0, leading: 0, bottom: 0, trailing: 0
//        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        // section.boundarySupplementaryItems = [sectionHeader]
        // section.interGroupSpacing = Specs.cellMargin
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Specs.margin, leading: Specs.margin,
            bottom: Specs.margin, trailing: Specs.margin
        )

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension GoalViewController2: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    private func cell(for path: IndexPath, model: GoalDetailsElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        switch model {
        case .details(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.details, for: path
            ) as? GoalDetailsCell else { return UICollectionViewCell() }
            cell.configure(for: data)
            return cell
            
        case .edit(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.edit, for: path
            ) as? GoalDetailsEditCell else { return UICollectionViewCell() }
            cell.configure(for: data)
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
