//
//  DeveloperViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DeveloperViewController: BaseTableViewController, DeveloperView {

    // MARK: - DI

    var presenter: DeveloperPresenterProtocol!

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    func loadData(_ sections: [Section]) {
        self.sections = sections
        var snapshot = NSDiffableDataSourceSnapshot<Section, Cell>()
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
}
