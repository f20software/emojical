//
//  GoalStreaksChartController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 9/19/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalStreaksChartController: UIViewController, GoalStreaksChartView {
    
    // MARK: - Outlets
    
    @IBOutlet var stats: UICollectionView!

    // MARK: - DI

    var presenter: ChartPresenterProtocol!
    private var dataBuilder: CalendarDataBuilder!

    // MARK: - State
    
    /// Private copy for the sort order value - used to configure cells
    private var _sortOrder: GoalStreakSortOrder = .totalCount

    private var sections = [String]()
    
    private var goalsData = [GoalStreakData2]()
    
    private var dataSource: UICollectionViewDiffableDataSource<String, GoalStreakData2>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = GoalStreaksChartPresenter(
            repository: Storage.shared.repository,
            awardManager: AwardManager.shared,
            stampsListener: Storage.shared.stampsListener(),
            calendar: CalendarHelper.shared,
            view: self)
        
        dataBuilder = CalendarDataBuilder(
            repository: Storage.shared.repository,
            calendar: CalendarHelper.shared
        )

        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - TodayView
    
    /// User tapped on total/streak counters
    var onCountersTapped: (() -> Void)?

    /// Load stats for the goal streaks
    func loadGoalStreaksData(data: [GoalStreakData2], sortOrder: GoalStreakSortOrder) {
        var snapshot = NSDiffableDataSourceSnapshot<String, GoalStreakData2>()
        sections = []
        _sortOrder = sortOrder

        switch sortOrder {
        case .totalCount:
            goalsData = data.sorted(by: { $0.count > $1.count })
        case .streakLength:
            goalsData = data.sorted(by: { $0.streak > $1.streak })
        }
            
        let weekly = goalsData.filter({ $0.period == .week })
        if weekly.count > 0 {
            snapshot.appendSections(["Weekly Goals"])
            sections.append("Weekly Goals")
            snapshot.appendItems(weekly)
        }

        let monthly = goalsData.filter({ $0.period == .month })
        if monthly.count > 0 {
            snapshot.appendSections(["Monthly Goals"])
            sections.append("Monthly Goals")
            snapshot.appendItems(monthly)
        }
        
        for cell in self.stats.visibleCells {
            if let c = cell as? GoalStreakCell2 {
                c.refreshCounters(sortOrder: sortOrder)
            }
        }

        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<String, GoalStreakData2>(
            collectionView: stats,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )
        
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView, kind, indexPath) -> UICollectionReusableView? in
            self?.header(for: indexPath, kind: kind, collectionView: collectionView)
        }

        stats.dataSource = dataSource
        stats.delegate = self
        stats.collectionViewLayout = goalStreaksLayout()
        stats.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        stats.register(
            UINib(nibName: "GoalStreakCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalStreakCell
        )
        stats.register(
            UINib(nibName: "GoalStreakCell2", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalStreakCell2
        )
        stats.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Specs.Cells.header
        )
    }

    // Creates layout for goal streak stats - one line per goal
    private func goalStreaksLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension GoalStreaksChartController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: GoalStreakData2, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.goalStreakCell2, for: path
        ) as? GoalStreakCell2 else { return UICollectionViewCell() }
        
        cell.configure(for: model, sortOrder: _sortOrder)
        cell.onCounterTapped = {
            self.onCountersTapped?()
        }
        return cell
    }
    
    private func header(for path: IndexPath, kind: String, collectionView: UICollectionView) ->
        UICollectionReusableView? {

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Specs.Cells.header,
            for: path) as? CollectionHeaderView else { return UICollectionReusableView() }

        header.configure(
            text: sections[path.section],
            font: Theme.main.fonts.statsSectionHeaderTitle,
            textColor: Theme.main.colors.text
        )
        return header
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Cell identifiers
    struct Cells {
        
        /// Custom supplementary header identifier and kind
        static let header = "stats-header-element"

        /// Goal streak cell
        static let goalStreakCell = "GoalStreakCell"

        /// Goal streak cell
        static let goalStreakCell2 = "GoalStreakCell2"
    }
}
