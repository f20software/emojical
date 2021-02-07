//
//  GoalsLibraryViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/6/2021.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalsLibraryViewController: UIViewController, GoalsLibraryView {

    // MARK: - Outlets
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cancelBarButton: UIBarButtonItem!

    // MARK: - DI

    lazy var coordinator: StickersCoordinatorProtocol = {
        StickersCoordinator(
            parent: self.navigationController!,
            repository: repository,
            awardManager: AwardManager.shared)
    }()

    var repository: DataRepository!
    var presenter: GoalsLibraryPresenterProtocol!
    
    // MARK: - State
    
    private var sections: [String] = [String]()
    private var dataSource: UICollectionViewDiffableDataSource<Int, GoalExampleData>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repository = Storage.shared.repository
        presenter = GoalsLibraryPresenter(
            repository: repository,
            view: self
        )
        
        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - GoalsLibraryView
    
    /// User tapped on the goal
    var onGoalTapped: ((String) -> Void)?

    /// User tapped on the Cancel button
    var onCancelTapped: (() -> Void)?

    /// Update page title
    func updateTitle(_ text: String) {
        title = text
    }

    /// Load data
    func loadData(sections: [String], goals: [GoalExampleData]) {
        
        self.sections = sections
        var snapshot = NSDiffableDataSourceSnapshot<Int, GoalExampleData>()
        var index = 0
        for section in self.sections {
            snapshot.appendSections([index])
            snapshot.appendItems(goals.filter({ $0.category == section }))
            index += 1
        }
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    /// Dismisses view if it was presented modally
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Action
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        onCancelTapped?()
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, GoalExampleData>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView, kind, indexPath) -> UICollectionReusableView? in
            self?.header(for: indexPath, kind: kind, collectionView: collectionView)
        }
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.collectionViewLayout = goalsLibraryLayout()
        collectionView.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        collectionView.register(
            UINib(nibName: "GoalExampleCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalExample
        )
        collectionView.register(
            StickersHeaderView.self,
            forSupplementaryViewOfKind: Specs.Cells.header,
            withReuseIdentifier: Specs.Cells.header
        )
    }
}

extension GoalsLibraryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GoalExampleCell else { return }
        
        onGoalTapped?(cell.title.text ?? "")
    }

    private func cell(for path: IndexPath, model: GoalExampleData, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.goalExample, for: path
        ) as? GoalExampleCell else { return UICollectionViewCell() }
        
        cell.configure(for: model)
        return cell
    }
    
    private func header(for path: IndexPath, kind: String, collectionView: UICollectionView) ->
        UICollectionReusableView? {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Specs.Cells.header,
            for: path) as? StickersHeaderView else { return UICollectionReusableView() }

        header.configure(sections[path.section])
        return header
    }
}

// MARK: - Collection view layout generation

extension GoalsLibraryViewController {

    // Creates collection layout based on the section required
    private func goalsLibraryLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 0, bottom: 0, trailing: 0
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
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
        section.interGroupSpacing = Specs.cellMargin
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Specs.margin,
            bottom: Specs.margin, trailing: Specs.margin
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Cell identifiers
    struct Cells {
        
        /// Sticker cell identifier
        static let goalExample = "GoalExampleCell"

        /// Custom supplementary header identifier and kind
        static let header = "stickers-header-element"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0

    /// Cell margin
    static let cellMargin: CGFloat = 16.0
}
