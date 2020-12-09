//
//  TodayViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

class StatsViewController: UIViewController, StatsView {
    
    // MARK: - Outlets
    
    @IBOutlet var prevWeek: UIBarButtonItem!
    @IBOutlet var nextWeek: UIBarButtonItem!

    @IBOutlet var header: UILabel!

    @IBOutlet var stats: UICollectionView!

    // MARK: - DI

    var presenter: StatsPresenterProtocol!
    
    // MARK: - State
    
    private var weekDataSource: UICollectionViewDiffableDataSource<Int, WeekElement>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = StatsPresenter(
            repository: Storage.shared.repository,
            stampsListener: Storage.shared.stampsListener(),
            awardsListener: Storage.shared.awardsListener(),
            awardManager: AwardManager.shared,
            calendar: CalendarHelper.shared,
            view: self)
        
        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - TodayView
    
    /// User tapped on the mode selector on the top of the screen
    var onModeChanged: ((Int) -> Void)?

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)?

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)? 

    /// Update page header
    func setHeader(to text: String) {
        header.text = text
    }

    /// Show/hide next week button
    func showNextWeekButton(_ show: Bool) {
        navigationItem.rightBarButtonItem = show ? nextWeek : nil
    }
    
    /// Show/hide previous week button
    func showPrevWeekButton(_ show: Bool) {
        navigationItem.leftBarButtonItem = show ? prevWeek : nil
    }

    /// Load stats for the week
    func loadWeekData(header: WeekHeaderData, data: [WeekLineData]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, WeekElement>()
        snapshot.appendSections([0])
        
        snapshot.appendItems([.weekHeader(header)])
        snapshot.appendItems(data.map({ WeekElement.weekLine($0) }))
        weekDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    // MARK: - Actions
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        onPrevWeekTapped?()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        onNextWeekTapped?()
    }
    
    // MARK: - Private helpers
    
    private func configureViews() {
        
        configureCollectionView()
        registerCells()
        
        prevWeek.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        nextWeek.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
    }
    
    private func configureCollectionView() {
        self.weekDataSource = UICollectionViewDiffableDataSource<Int, WeekElement>(
            collectionView: stats,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )

        stats.dataSource = weekDataSource
        stats.delegate = self
        stats.collectionViewLayout = weekLayout()
        stats.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        stats.register(
            UINib(nibName: "WeekLineCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.weekLine
        )
        stats.register(
            UINib(nibName: "WeekHeaderCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.weekHeader
        )
    }


    // Creates layout for the day column - vertical list of cells
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
//        section.contentInsets = NSDirectionalEdgeInsets(
//            top: 0, leading: 5,
//            bottom: 0, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }

}

extension StatsViewController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: WeekElement, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        switch model {
        case .weekHeader(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.weekHeader, for: path
            ) as? WeekHeaderCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
            return cell

        case .weekLine(let data):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Specs.Cells.weekLine, for: path
            ) as? WeekLineCell else { return UICollectionViewCell() }
            
            cell.configure(for: data)
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
        static let weekLine = "WeekLineCell"
    }
}
