//
//  StickersViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickersViewController: UIViewController, StickersView {

    // List of sections
    enum Section: String, CaseIterable {
        case stickers = "stickers_title"
        case goals = "goals_section_title"
    }

    // MARK: - Outlets
    
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!

    // MARK: - DI

    lazy var coordinator: StickersCoordinatorProtocol = {
        StickersCoordinator(
            parent: self.navigationController!,
            repository: repository,
            awardManager: AwardManager.shared)
    }()

    var repository: DataRepository!
    var presenter: StickersPresenterProtocol!
    
    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StickersElement>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repository = Storage.shared.repository
        presenter = StickersPresenter(
            repository: repository,
            stampsListener: Storage.shared.stampsListener(),
            goalsListener: Storage.shared.goalsListener(),
            awardsListener: Storage.shared.awardsListener(),
            awardManager: AwardManager.shared,
            view: self,
            coordinator: coordinator)
        
        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - StickersView
    
    /// Return UIViewController instance (so we can present alert stuff from Presenter class)
    var viewController: UIViewController? {
        return self
    }

    /// User tapped on the sticker
    var onStickerTapped: ((Int64) -> Void)?

    /// User tapped on the goal
    var onGoalTapped: ((Int64) -> Void)?

    /// User tapped on create new goal button
    var onNewGoalTapped: (() -> Void)?

    /// User tapped on create new sticker button
    var onNewStickerTapped: (() -> Void)?

    /// User tapped on Add button
    var onAddButtonTapped: (() -> Void)?

    /// User tapped on Goals Examples button
    var onGoalsExamplesTapped: (() -> Void)?

    /// Update page title
    func updateTitle(_ text: String) {
        title = text
    }

    /// Load data
    func loadData(stickers: [StickerData], goals: [GoalData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StickersElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(stickers.map({ StickersElement.sticker($0) }))
        snapshot.appendItems([.newSticker])
        snapshot.appendSections([1])
        snapshot.appendItems(goals.map({ StickersElement.goal($0) }))
        if goals.count == 0 {
            snapshot.appendItems([.noGoals("no_goals_description".localized)])
        }
        snapshot.appendItems([.newGoal])
        if goals.count == 0 {
            snapshot.appendItems([.noGoals("looking_for_examples".localized)])
            snapshot.appendItems([.fromLibrary])
        }
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        onAddButtonTapped?()
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()

        addButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, StickersElement>(
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
        collectionView.collectionViewLayout = generateLayout()
        collectionView.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        collectionView.register(
            UINib(nibName: "StickerCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.stickerCell
        )
        collectionView.register(
            UINib(nibName: "GoalCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalCell
        )
        collectionView.register(
            UINib(nibName: "NewGoalCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.newGoalCell
        )
        collectionView.register(
            UINib(nibName: "NewStickerCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.newStickerCell
        )
        collectionView.register(
            UINib(nibName: "NoGoalsCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.noGoalsCell
        )
        collectionView.register(
            UINib(nibName: "GoalsLibraryCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalsExamplesCell
        )
        collectionView.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: Specs.Cells.header,
            withReuseIdentifier: Specs.Cells.header
        )
    }
}

extension StickersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let cell = collectionView.cellForItem(at: indexPath) as? StickerCell {
            onStickerTapped?(Int64(cell.tag))
        } else if (collectionView.cellForItem(at: indexPath) as? NewStickerCell) != nil {
            onNewStickerTapped?()
        } else if let cell = collectionView.cellForItem(at: indexPath) as? GoalCell {
            onGoalTapped?(Int64(cell.tag))
        } else if (collectionView.cellForItem(at: indexPath) as? NewGoalCell) != nil {
            onNewGoalTapped?()
        } else if (collectionView.cellForItem(at: indexPath) as? GoalsLibraryCell) != nil {
            onGoalsExamplesTapped?()
        }
    }

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
            ) as? GoalCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell

        case .noGoals(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.noGoalsCell, for: path
            ) as? NoGoalsCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell

        case .newSticker:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.newStickerCell, for: path
            ) as? NewStickerCell else { return UICollectionViewCell() }
            return cell

        case .newGoal:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.newGoalCell, for: path
            ) as? NewGoalCell else { return UICollectionViewCell() }
            return cell

        case .fromLibrary:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.goalsExamplesCell, for: path
            ) as? GoalsLibraryCell else { return UICollectionViewCell() }
            return cell
        }
    }
    
    private func header(for path: IndexPath, kind: String, collectionView: UICollectionView) ->
        UICollectionReusableView? {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Specs.Cells.header,
            for: path) as? CollectionHeaderView else { return UICollectionReusableView() }

        header.configure(Section.allCases[path.section].rawValue.localized)
        return header
    }
}

// MARK: - Collection view layout generation

extension StickersViewController {

    // Creates collection layout based on the section required
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, _) -> NSCollectionLayoutSection? in
        
            let section = Section.allCases[sectionIndex]
            switch (section) {
            case .stickers:
                return self.generateStampsLayout()
            case .goals:
                return self.generateGoalsLayout()
            }
        }
        return layout
    }
    
    // Generates layout for stickers section - each sticker is fixed width square cell
    private func generateStampsLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.165), // .absolute(64),
                heightDimension: .fractionalWidth(0.165) // .absolute(64)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 0,
            bottom:  Specs.cellMargin, trailing: Specs.cellMargin
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
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Specs.margin,
            bottom: 0, trailing: Specs.margin
        )
        
        return section
    }
    
    // Generates layout for goals section - each line is 100% width
    private func generateGoalsLayout() -> NSCollectionLayoutSection {
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
        
        return section
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
        
        /// New goal cell identifier
        static let newGoalCell = "NewGoalCell"

        /// New sticker cell identifier
        static let newStickerCell = "NewStickerCell"

        /// No goals cell identifier
        static let noGoalsCell = "NoGoalsCell"

        /// Goals examples cell identifier
        static let goalsExamplesCell = "GoalsLibraryCell"

        /// Custom supplementary header identifier and kind
        static let header = "stickers-header-element"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0

    /// Cell margin
    static let cellMargin: CGFloat = 16.0
}
