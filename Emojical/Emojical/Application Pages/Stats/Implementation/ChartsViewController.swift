//
//  ChartsViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 6/20/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class ChartsViewController: UIViewController, ChartsView {
    
    // MARK: - Outlets
    
    @IBOutlet var charts: UICollectionView!

    // MARK: - DI

    var presenter: ChartsPresenterProtocol!
    var repository: DataRepository!

    lazy var coordinator: ChartsCoordinatorProtocol = {
        ChartsCoordinator(
            parent: self.navigationController!,
            repository: repository
        )
    }()

    // MARK: - State
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, ChartType>!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repository = Storage.shared.repository
        presenter = ChartsPresenter(
            repository: repository,
            view: self,
            coordinator: coordinator)

        configureViews()
        presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    // MARK: - ChartsView
    
    /// User tapped on selected chart
    var onChartTapped: ((Int) -> Void)?

    /// Update page title
    func updateTitle(_ text: String) {
        title = text
    }
    
    /// Load list of charts
    func loadChartsData(_ data: [ChartType]) {
        
        // Clear existing data to eliminate animation glitches
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChartType>()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureCollectionView()
        registerCells()
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, ChartType>(
            collectionView: charts,
            cellProvider: { [weak self] (collectionView, path, model) -> UICollectionViewCell? in
                self?.cell(for: path, model: model, collectionView: collectionView)
            }
        )
        charts.dataSource = dataSource
        charts.delegate = self
        charts.collectionViewLayout = chartsLayout()
        charts.backgroundColor = UIColor.clear
    }
    
    private func registerCells() {
        charts.register(
            UINib(nibName: "ChartCell", bundle: .main),
            forCellWithReuseIdentifier: Specs.Cells.chart
        )
    }

    // Creates layout for weekly stats - one line per stamp
    private func chartsLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension ChartsViewController: UICollectionViewDelegate {
    
    private func cell(for path: IndexPath, model: ChartType, collectionView: UICollectionView) -> UICollectionViewCell? {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Specs.Cells.chart, for: path
        ) as? ChartCell else { return UICollectionViewCell() }
            
        cell.configure(for: model.toDetailModel())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onChartTapped?(indexPath.row)
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Cell identifiers
    struct Cells {
        
        /// Chart cell
        static let chart = "ChartCell"
    }
}
