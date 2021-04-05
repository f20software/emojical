//
//  StatsViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/09/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, StatsView {
    
    // MARK: - Outlets
    
    @IBOutlet var modeSelector: UISegmentedControl!
    @IBOutlet var prevButton: UIBarButtonItem!
    @IBOutlet var nextButton: UIBarButtonItem!
    @IBOutlet var header: UILabel!
    @IBOutlet var stats: UICollectionView!

    // MARK: - DI

    var presenter: StatsPresenterProtocol!
    private var dataBuilder: CalendarDataBuilder!

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, StatsElement>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = StatsPresenter(
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
    
    /// User tapped on the mode selector on the top of the screen
    var onModeChanged: ((StatsMode) -> Void)?

    /// User tapped on the previous week button
    var onPrevButtonTapped: (() -> Void)?

    /// User tapped on the next week button
    var onNextButtonTapped: (() -> Void)? 

    /// Update page title
    func updateTitle(_ text: String) {
        title = text
    }

    /// Update page header
    func setHeader(to text: String) {
        header.text = text
    }

    /// Update collection view layout to appropriate mode
    func updateLayout(to mode: StatsMode) {
        // Updated UI just in case 
        modeSelector.selectedSegmentIndex = mode.rawValue
        
        // Clear existing data to eliminate animation glitches
        var snapshot = NSDiffableDataSourceSnapshot<Int, StatsElement>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
        
        switch mode {
//        case .week:
//            self.stats.collectionViewLayout = self.weekLayout()
            
        case .month:
            self.stats.collectionViewLayout = self.monthLayout()

//        case .year:
//            self.stats.collectionViewLayout = self.weekLayout()

        case .goalStreak:
            self.stats.collectionViewLayout = self.goalStreaksLayout()
        }
    }

    /// Show/hide next/prev button
    func showNextPrevButtons(showPrev: Bool, showNext: Bool) {
        navigationItem.leftBarButtonItem = showPrev ? prevButton : nil
        navigationItem.rightBarButtonItem = showNext ? nextButton : nil
    }
    
    /// Load stats for the week
    func loadWeekData(header: WeekHeaderData, data: [WeekLineData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StatsElement>()
        snapshot.appendSections([0])
        snapshot.appendItems([.weekHeaderCell(header)])
        snapshot.appendItems(data.map({ StatsElement.weekLineCell($0) }))
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    /// Load stats for the month
    func loadMonthData(data: [MonthBoxData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StatsElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(data.map({ StatsElement.monthBoxCell($0) }))
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    /// Load stats for the goal streaks
    func loadGoalStreaksData(data: [GoalStreakData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StatsElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(data.map({ StatsElement.goalStreakCell($0) }))
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    /// Load stats for the year
    func loadYearData(data: [YearBoxData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, StatsElement>()
        snapshot.appendSections([0])
        snapshot.appendItems(data.map({ StatsElement.yearBoxCell($0) }))
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }


    // MARK: - Actions
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        onPrevButtonTapped?()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        onNextButtonTapped?()
    }
    
    @IBAction func modeChanged(_ sender: Any) {
        guard let control = sender as? UISegmentedControl,
            let newMode = StatsMode(rawValue: control.selectedSegmentIndex) else { return }
        onModeChanged?(newMode)
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {

        configureCollectionView()
        registerCells()
        
        prevButton.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        nextButton.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        
        modeSelector.setTitle("month_stickers".localized.capitalizingFirstLetter(), forSegmentAt: 0)
        modeSelector.setTitle("goal_streaks".localized.capitalizingFirstLetter(), forSegmentAt: 1)
    }
    
    private func configureCollectionView() {
        self.dataSource = UICollectionViewDiffableDataSource<Int, StatsElement>(
            collectionView: stats,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )
        stats.dataSource = dataSource
        stats.delegate = self
        stats.collectionViewLayout = weekLayout()
        stats.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        stats.register(
            UINib(nibName: "WeekLineCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.weekStickerStatsCell
        )
        stats.register(
            UINib(nibName: "WeekHeaderCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.weekHeader
        )
        stats.register(
            UINib(nibName: "MonthBoxCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.monthStickerStatsCell
        )
        stats.register(
            UINib(nibName: "GoalStreakCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.goalStreakCell
        )
        stats.register(
            UINib(nibName: "YearBoxCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.yearStickerStatsCell
        )
    }


    // Creates layout for weekly stats - one line per stamp
    private func weekLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
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

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }

    // Creates layout for monthly stats - each month inside box cell
    private func monthLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.49),
                heightDimension: .estimated(100)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Specs.monthBoxesMargin,
            bottom: 0, trailing: Specs.monthBoxesMargin)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 0,
            bottom: Specs.monthBoxesMargin, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension StatsViewController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: StatsElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        switch model {
        case .weekHeaderCell(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.weekHeader, for: path
            ) as? WeekHeaderCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell

        case .weekLineCell(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.weekStickerStatsCell, for: path
            ) as? WeekLineCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell
            
        case .monthBoxCell(let model):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.monthStickerStatsCell, for: path
            ) as? MonthBoxCell else { return UICollectionViewCell() }
            
            cell.configure(for: model, getData: { completion in
                let month = CalendarHelper.Month(Date(yyyyMmDd: model.firstDayKey))
                self.dataBuilder.monthlyStatsForStampAsync(stampId: model.stampId, month: month) { (data) in
                    completion(model.primaryKey, data)
                }
            })
            return cell

        case .yearBoxCell(let model):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.yearStickerStatsCell, for: path
            ) as? YearBoxCell else { return UICollectionViewCell() }
            
            cell.configure(for: model, getData: { completion in
                let year = CalendarHelper.Year(model.year)
                self.dataBuilder.yearlyStatsForStampAsync(stampId: model.stampId, year: year) { (data) in
                    completion(model.primaryKey, data)
                }
            })
            return cell

        case .goalStreakCell(let model):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.goalStreakCell, for: path
            ) as? GoalStreakCell else { return UICollectionViewCell() }
            
            cell.configure(for: model)
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Cell identifiers
    struct Cells {
        
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
    }
    
    /// Margins for monthly boxes (from left, right, and bottom)
    static let monthBoxesMargin: CGFloat = 15.0
}
