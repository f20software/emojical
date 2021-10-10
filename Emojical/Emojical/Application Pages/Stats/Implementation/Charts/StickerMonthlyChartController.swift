//
//  StickerMonthlyChartController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class StickerMonthlyChartController: UIViewController, StickerMonthlyChartView {
    
    // MARK: - Outlets
    
    @IBOutlet var prevButton: UIBarButtonItem!
    @IBOutlet var nextButton: UIBarButtonItem!
    @IBOutlet var chart: UICollectionView!

    // MARK: - DI

    var presenter: ChartPresenterProtocol!
    private var dataBuilder: CalendarDataBuilder!

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, MonthBoxData>!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    /// User tapped on the previous week button
    var onPrevButtonTapped: (() -> Void)?

    /// User tapped on the next week button
    var onNextButtonTapped: (() -> Void)? 

    /// Show/hide next/prev button
    func showNextPrevButtons(showPrev: Bool, showNext: Bool) {
        nextButton.isEnabled = showNext
        prevButton.isEnabled = showPrev
    }
    
    /// Load stats for the month
    func loadMonthData(header: String, data: [MonthBoxData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MonthBoxData>()
        title = header
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    // MARK: - Actions
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        onPrevButtonTapped?()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        onNextButtonTapped?()
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {

        configureCollectionView()
        registerCells()
        
        prevButton.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        nextButton.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, MonthBoxData>(
            collectionView: chart,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        chart.dataSource = dataSource
        chart.delegate = self
        chart.collectionViewLayout = monthLayout()
        chart.backgroundColor = UIColor.clear
    }

    private func registerCells() {
        chart.register(
            UINib(nibName: "MonthBoxCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.monthStickerStatsCell
        )
    }

    // Creates layout for monthly stats - each month inside box cell
    private func monthLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(220)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(220)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Specs.monthBoxesMargin, leading: Specs.monthBoxesMargin,
            bottom: Specs.monthBoxesMargin, trailing: Specs.monthBoxesMargin - 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension StickerMonthlyChartController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: MonthBoxData, collectionView: UICollectionView) -> UICollectionViewCell? {
        
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
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Cell identifiers
    struct Cells {
        
        /// Month stat cell
        static let monthStickerStatsCell = "MonthBoxCell"
    }
    
    /// Margins for monthly boxes (from left, right, and bottom)
    static let monthBoxesMargin: CGFloat = 15.0
}
