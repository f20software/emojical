//
//  GoalsViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 5/1/2022.
//  Copyright © 2022 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController, GoalsView {

    // MARK: - Outlets
    
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!

    // MARK: - DI

    lazy var coordinator: GoalsCoordinatorProtocol = {
        GoalsCoordinator(
            parent: self.navigationController!,
            repository: repository,
            awardManager: AwardManager.shared)
    }()

    var repository: DataRepository!
    var presenter: GoalsPresenterProtocol!
    
    // MARK: - State
    
    // Store section titles (weekly / monthly / etc)
    private var sectionTitles: [String] = []
    
    // Data source for all goals
    private var dataSource: UICollectionViewDiffableDataSource<String, GoalsElement>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repository = Storage.shared.repository
        presenter = GoalsPresenter(
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

    /// User tapped on the goal
    var onGoalTapped: ((Int64) -> Void)?

    /// User tapped on create new goal button
    var onNewGoalTapped: (() -> Void)?

    /// User tapped on Add button
    var onAddButtonTapped: (() -> Void)?

    /// User tapped on Goals Examples button
    var onGoalsExamplesTapped: (() -> Void)?

    /// Update page title
    func updateTitle(_ text: String) {
        title = text
    }

    /// Load data
    func loadData(goals: [GoalData]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, GoalsElement>()
        sectionTitles.removeAll()
        
        defer {
            dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
        
        // No goals? Special empty cell with buttons and description
        if goals.count == 0 {
            snapshot.appendSections([""])
            sectionTitles.append("")

            snapshot.appendItems([
                .noGoals(NoGoalsData(
                    icon: Theme.main.images.crown,
                    instructions: "no_goals_description".localized,
                    buttonA: "create_goal_button".localized,
                    buttonB: "goals_examples_button".localized)
                )
            ])
            return
        }

        // Go through all periods and include them if there are goals
        let allPeriods = Period.allCases
        allPeriods.forEach({ period in
            let filtered = goals.filter({ $0.period == period })
            if filtered.count > 0 {
                snapshot.appendSections([period.sectionTitle])
                sectionTitles.append(period.sectionTitle)
                snapshot.appendItems(filtered.map({ GoalsElement.goal($0) }))
            }
        })
        
        snapshot.appendItems([.newGoal])
    }

    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        onAddButtonTapped?()
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()

        addButton.image = Theme.main.images.plusButton
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<String, GoalsElement>(
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
            UINib(nibName: "GoalCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalCell
        )
        collectionView.register(
            UINib(nibName: "NewGoalCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.newGoalCell
        )
        collectionView.register(
            UINib(nibName: "NoGoalsCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.noGoalsCell
        )
        collectionView.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: Specs.Cells.header,
            withReuseIdentifier: Specs.Cells.header
        )
    }
}

extension GoalsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GoalCell {
            cell.updateHighlightedState()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GoalCell {
            cell.updateHighlightedState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let cell = collectionView.cellForItem(at: indexPath) as? GoalCell {       onGoalTapped?(Int64(cell.tag))
        } else if (collectionView.cellForItem(at: indexPath) as? NewGoalCell) != nil {
            onNewGoalTapped?()
        }
        
    }

    private func cell(for path: IndexPath, model: GoalsElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        switch model {

        case .goal(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.goalCell, for: path
            ) as? GoalCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell

        case .newGoal:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.newGoalCell, for: path
            ) as? NewGoalCell else { return UICollectionViewCell() }
            return cell

        case .noGoals(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.noGoalsCell, for: path
            ) as? NoGoalsCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            cell.onButtonATapped = {
                self.onNewGoalTapped?()
            }
            cell.onButtonBTapped = {
                self.onGoalsExamplesTapped?()
            }
            return cell
        }
    }
    
    private func header(for path: IndexPath, kind: String, collectionView: UICollectionView) ->
        UICollectionReusableView? {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Specs.Cells.header,
            for: path) as? CollectionHeaderView else { return UICollectionReusableView() }

        header.configure(sectionTitles[path.section].localized)
        return header
    }
}

// MARK: - Collection view layout generation

extension GoalsViewController {

    // Creates collection layout based on the section required
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, _) -> NSCollectionLayoutSection? in
        
            return self.generateGoalsLayout()
        }
        return layout
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
        
        /// Goal cell identifier
        static let goalCell = "GoalCell"
        
        /// New goal cell identifier
        static let newGoalCell = "NewGoalCell"

        /// No goals cell identifier
        static let noGoalsCell = "NoGoalsCell"

        /// Custom supplementary header identifier and kind
        static let header = "stickers-header-element"
    }
    
    /// Left/right and bottom margin for the collection view cells
    static let margin: CGFloat = 20.0

    /// Cell margin
    static let cellMargin: CGFloat = 16.0
}
