//
//  OptionsViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController, OptionsView {

    private var dataSource: OptionsDataSource!

    // MARK: - Data source
    
    private var sections = [OptionsSection]()

    // MARK: - DI

    var presenter: OptionsPresenterProtocol!

    lazy var coordinator: OptionsCoordinatorProtocol = {
        OptionsCoordinator(
            parent: self.navigationController!
        )
    }()

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = OptionsPresenter(
            view: self,
            settings: LocalSettings.shared,
            coordinator: coordinator)
        
        configureViews()
        presenter.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }

    // MARK: - OptionsView
    
    /// Return UIViewController instance (so we can present and mail stuff from Presenter class)
    var viewController: UIViewController? {
        return self
    }
    
    /// Load view data
    func loadData(_ sections: [OptionsSection]) {
        self.sections = sections
        var snapshot = NSDiffableDataSourceSnapshot<OptionsSection, OptionsCell>()
        for section in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(section.cells)
        }
        dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        configureTableView()
    }
    
    private func configureTableView() {
        dataSource = OptionsDataSource(
            tableView: tableView,
            cellProvider: { [weak self] (tableView, path, model) -> UITableViewCell? in
                self?.cell(for: path, model: model, tableView: tableView)
            }
        )
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.backgroundColor = Theme.shared.colors.background
    }
    
    @IBAction func significantTimeChange(_ sender: Any) {
//        NotificationCenter.default.post(name: UIApplication.significantTimeChangeNotification, object: nil)
    }

    @IBAction func navigateToToday(_ sender: Any) {
//        NotificationCenter.default.post(name: .navigateToToday, object: nil)
    }

    @IBAction func weekRecapIsReady(_ sender: Any) {
//        NotificationCenter.default.post(name: .weekClosed, object: nil)
    }
}

// MARK: - TableView support

extension OptionsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath) as? OptionsNavigateCell {
            cell.onSelected?()
        } else if let cell = tableView.cellForRow(at: indexPath) as? OptionsButtonCell {
            cell.onButtonTapped?()
        }
    }
    
    private func cell(for path: IndexPath, model: OptionsCell, tableView: UITableView) -> UITableViewCell? {
        switch model {
        case .text(let text):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.textCell)
                as? OptionsTextCell else { return UITableViewCell() }
            cell.configure(for: text)
            return cell
            
        case .button(let text, let callback):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.buttonCell)
                as? OptionsButtonCell else { return UITableViewCell() }
            cell.configure(for: text)
            cell.onButtonTapped = callback
            return cell
            
        case .navigate(let text, let callback):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.navigationCell)
                as? OptionsNavigateCell else { return UITableViewCell() }
            cell.configure(for: text)
            cell.onSelected = callback
            return cell

        case .`switch`(let text, let value, let callback):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.switchCell)
                as? OptionsSwitchCell else { return UITableViewCell() }
            cell.configure(for: text, value: value)
            cell.onValueChanged = callback
            return cell
        }
    }
}

// MARK: - Specs
fileprivate struct Specs {

    /// Cell identifiers
    struct Cells {
        
        /// Sticker cell identifier
        static let textCell = "textCell"
        
        /// Sticker cell identifier
        static let buttonCell = "buttonCell"

        /// Sticker cell identifier
        static let switchCell = "switchCell"

        /// Sticker cell identifier
        static let navigationCell = "navigationCell"
    }
}
