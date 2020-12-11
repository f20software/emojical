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
        case stickers = "Stickers"
        case goals = "Goals"
    }

    // MARK: - Outlets
    
    @IBOutlet var collectionView: UICollectionView!

    // MARK: - DI

    var repository: DataRepository!
    var presenter: StickersPresenterProtocol!
    
    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StickersElement>!

    // Editing goal Id... :(
    var editGoalId: Int64?
    var editStampId: Int64?

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
            coordinator: self)
        
        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - StickersView
    
    /// User tapped on the sticker
    var onStickerTapped: ((Int64) -> Void)?

    /// User tapped on the goal
    var onGoalTapped: ((Int64) -> Void)?

    /// User tapped on create new goal button
    var onNewGoalTapped: (() -> Void)?

    /// User tapped on create new sticker button
    var onNewStickerTapped: (() -> Void)?

    /// Load data
    func loadData(stickers: [DayStampData], goals: [GoalAwardData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StickersElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(stickers.map({ StickersElement.sticker($0) }))
        snapshot.appendItems([.newSticker])
        snapshot.appendSections([1])
        snapshot.appendItems(goals.map({ StickersElement.goal($0) }))
        snapshot.appendItems([.newGoal])
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    // MARK: - Actions
    
    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()
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
            UINib(nibName: "Goal2Cell", bundle: .main),
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
            StickersHeaderView.self,
            forSupplementaryViewOfKind: Specs.Cells.header,
            withReuseIdentifier: Specs.Cells.header
        )
    }
}

// MARK: - StickerCoordinator

extension StickersViewController: StickersCoordinator {
    
    func editGoal(_ goalId: Int64) {
        editGoalId = goalId
        performSegue(withIdentifier: "editGoal", sender: self)
    }
    
    func newGoal() {
        editGoalId = nil
        performSegue(withIdentifier: "newGoal", sender: self)
    }

    func editSticker(_ stampId: Int64) {
        editStampId = stampId
        performSegue(withIdentifier: "editSticker", sender: self)
    }
    
    func newSticker() {
        editStampId = nil
        performSegue(withIdentifier: "newSticker", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGoal" {
            let goal = repository.goalById(editGoalId!)!
            // DataSource.shared.updateStatsForGoal(&goal)
            let controller = segue.destination as! GoalViewController
            controller.title = goal.name
            controller.goal = goal
            controller.currentProgress = AwardManager.shared.currentProgressFor(goal)
            controller.presentationMode = .push
        }
        else if segue.identifier == "newGoal" {
            setEditing(false, animated: true)
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.viewControllers.first as! GoalViewController
            controller.title = "New Goal"
            controller.goal = Goal(id: nil, name: "New Goal", period: .week, direction: .positive, limit: 5, stamps: [])
            controller.presentationMode = .modal
        }
        else if segue.identifier == "editSticker" {
            let stamp = repository.stampById(editStampId!)!
            // DataSource.shared.updateStatsForStamp(stamp)
            let controller = segue.destination as! StampViewController
            controller.stamp = stamp
            controller.presentationMode = .push
        }
        else if segue.identifier == "newSticker" {
            setEditing(false, animated: true)
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.viewControllers.first as! StampViewController
            controller.stamp = Stamp.defaultStamp
            controller.presentationMode = .modal
        }
    }

}

extension StickersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = collectionView.cellForItem(at: indexPath)?.tag else { return }
        
        let section = Section.allCases[indexPath.section]
        switch (section) {
        case .stickers:
            if tag > 0 {
                onStickerTapped?(Int64(tag))
            } else {
                onNewStickerTapped?()
            }
        case .goals:
            if tag > 0 {
                onGoalTapped?(Int64(tag))
            } else {
                onNewGoalTapped?()
            }
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
            ) as? Goal2Cell else { return UICollectionViewCell() }
            
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
        }
    }
    
    private func header(for path: IndexPath, kind: String, collectionView: UICollectionView) ->
        UICollectionReusableView? {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Specs.Cells.header,
            for: path) as? StickersHeaderView else { return UICollectionReusableView() }

        header.configure(Section.allCases[path.section].rawValue)
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
                widthDimension: .absolute(64),
                heightDimension: .absolute(64)
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
        static let goalCell = "Goal2Cell"
        
        /// New goal cell identifier
        static let newGoalCell = "NewGoalCell"

        /// New sticker cell identifier
        static let newStickerCell = "NewStickerCell"

        /// Custom supplementary header identifier and kind
        static let header = "stickers-header-element"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0

    /// Cell margin
    static let cellMargin: CGFloat = 16.0
}
