//
//  GoalSteaksController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 9/19/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class GoalStreaksController: UIViewController, GoalStreaksView {
    
    // MARK: - Outlets
    
    @IBOutlet var stats: UICollectionView!

    // MARK: - DI

    var presenter: ChartPresenterProtocol!
    private var dataBuilder: CalendarDataBuilder!

    // MARK: - State
    
    private var sections = [String]()
    private var maxCount: Float = 5.0
    private var maxStreak: Float = 5.0
    
    private var sortByCount: Bool = true
    private var goalsData = [GoalStreakData2]()
    
    private var dataSource: UICollectionViewDiffableDataSource<String, StatsElement>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = GoalStreaksPresenter(
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
    
    /// Load stats for the goal streaks
    func loadGoalStreaksData(data: [GoalStreakData2]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, StatsElement>()
        sections = []

        if sortByCount {
            goalsData = data.sorted(by: { $0.count > $1.count })
        } else {
            goalsData = data.sorted(by: { $0.streak > $1.streak })
        }

        maxCount = Float(goalsData.map({ $0.count }).max() ?? 0)
        maxStreak = Float(goalsData.map({ $0.streak }).max() ?? 0)
        if maxCount <= 1 { maxCount = 4 }
        if maxStreak <= 1 { maxStreak = 4 }

        let weekly = data.filter({ $0.period == .week })
        if weekly.count > 0 {
            snapshot.appendSections(["Weekly Goals"])
            sections.append("Weekly Goals")
            snapshot.appendItems(weekly.map({ StatsElement.goalStreakCell($0) }))
        }

        let monthly = data.filter({ $0.period == .month })
        if monthly.count > 0 {
            snapshot.appendSections(["Monthly Goals"])
            sections.append("Monthly Goals")
            snapshot.appendItems(monthly.map({ StatsElement.goalStreakCell($0) }))
        }
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<String, StatsElement>(
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
            forSupplementaryViewOfKind: Specs.Cells.header,
            withReuseIdentifier: Specs.Cells.header
        )
    }

    // Creates layout for goal streak stats - one line per goal
    private func goalStreaksLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)
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
            top: 0, leading: Specs.monthBoxesMargin,
            bottom: 0, trailing: Specs.monthBoxesMargin
        )

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension GoalStreaksController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: StatsElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        switch model {
        case .goalStreakCell(let model):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.goalStreakCell2, for: path
            ) as? GoalStreakCell2 else { return UICollectionViewCell() }
            
            if path.section == 0 {
                cell.configure(for: model, maxTotal: maxCount, maxStreak: maxStreak)
            } else {
                cell.configure(for: model, maxTotal: maxCount / 4, maxStreak: maxStreak / 4)
            }
//            cell.onCellTapped = { _ in
//                self.sortByCount = !self.sortByCount
//                self.loadGoalStreaksData(data: self.goalsData)
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                cell.animateProgress()
            })
            return cell
        default:
            return nil
        }
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

        /// Week header cell
        static let weekHeader = "WeekHeaderCell"

        /// Week stat line cell
        static let weekStickerStatsCell = "WeekLineCell"

        /// Month stat cell
        static let monthStickerStatsCell = "MonthBoxCell"

        /// Year stat cell
        static let yearStickerStatsCell = "YearBoxCell"
        
        /// Goal streak cell
        static let goalStreakCell = "GoalStreakCell"

        /// Goal streak cell
        static let goalStreakCell2 = "GoalStreakCell2"
    }
    
    /// Margins for monthly boxes (from left, right, and bottom)
    static let monthBoxesMargin: CGFloat = 15.0
}
