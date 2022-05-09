//
//  GoalStatsChartController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 9/19/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalStatsChartController: UIViewController, GoalStatsChartView {

    /// Seciton definitions
    struct Section {
        /// Filtering goals by period
        let period: Period
        
        /// Section title
        let title: String
        
        /// Chart title
        let chartTitle: String
    }

    /// Number of last period to display in the chart
    static let chartLength: Int = 12
    
    /// Two possible sections
    private var allSections: [Section] = [
        Section(
            period: .month,
            title: Period.month.sectionTitle,
            chartTitle: "monthly_goal_chart_title".localized("\(chartLength)")
        ),
        Section(
            period: .week,
            title: Period.week.sectionTitle,
            chartTitle: "weekly_goal_chart_title".localized("\(chartLength)")
        )
    ]

    // MARK: - Outlets
    
    @IBOutlet var stats: UICollectionView!

    // MARK: - DI

    var presenter: ChartPresenterProtocol!

    // MARK: - State
    
    /// Private copy for the sort order value - used to configure cells
    private var _sortOrder: GoalStatsSortOrder = .totalCount {
        didSet {
            // Need to update chart title, section headers and visible cells
            title = _sortOrder.title
            
            for cell in stats.visibleCells {
                if let c = cell as? GoalStatsCell {
                    c.updateCounter(primary: _sortOrder == .totalCount)
                }
            }
            
            for header in stats.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) {
                if let s = header as? GoalStatsHeaderView {
                    s.updateCol1(text: _sortOrder.columnTitle.uppercased())
                }
            }
        }
    }

    /// Internal array of section titles
    private var sections = [String]()
    
    /// Diffable data source
    private var dataSource: UICollectionViewDiffableDataSource<String, GoalStats>!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - TodayView
    
    /// Load stats for the goal streaks
    func loadGoalsData(data: [GoalStats], sortOrder: GoalStatsSortOrder) {
        var snapshot = NSDiffableDataSourceSnapshot<String, GoalStats>()
        sections = []

        var sorted: [GoalStats] = []
        switch sortOrder {
        case .totalCount:
            sorted = data.sorted(by: { $0.count > $1.count })
        case .streakLength:
            sorted = data.sorted(by: { $0.streak > $1.streak })
        }
            
        for section in allSections {
            let filteredData = sorted.filter({ $0.period == section.period })
            if filteredData.count > 0 {
                snapshot.appendSections([section.title])
                sections.append(section.title)
                snapshot.appendItems(filteredData)
            }
        }

        dataSource.apply(snapshot, animatingDifferences: true, completion: {
            // Update internal sort order and trigger updating visible UI reflecting new value
            self._sortOrder = sortOrder
        })
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<String, GoalStats>(
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
        stats.collectionViewLayout = goalsLayout()
        stats.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        stats.register(
            UINib(nibName: "GoalStatsCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalCell
        )
        stats.register(
            GoalStatsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Specs.Cells.header
        )
    }

    // Creates layout for goal streak stats - one line per goal
    private func goalsLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.showsSeparators = false
        config.headerMode = .supplementary
        config.backgroundColor = Theme.main.colors.background
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension GoalStatsChartController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: GoalStats, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.goalCell, for: path
        ) as? GoalStatsCell else { return UICollectionViewCell() }
        
        cell.configure(
            for: model,
            chartCount: GoalStatsChartController.chartLength,
            primary: _sortOrder == .totalCount
        )
        return cell
    }
    
    private func header(for path: IndexPath, kind: String, collectionView: UICollectionView) ->
        UICollectionReusableView? {

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Specs.Cells.header,
            for: path) as? GoalStatsHeaderView else { return UICollectionReusableView() }

        header.configure(
            headerText: sections[path.section],
            col1HeaderText: _sortOrder.columnTitle,
            col2HeaderText: allSections.first(where: { $0.title == sections[path.section] })?.chartTitle
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

        /// Goal cell
        static let goalCell = "GoalStatsCell"
    }
}
