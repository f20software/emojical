//
//  OptionsViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class OptionsViewController: BaseTableViewController, OptionsView {

    // MARK: - DI

    var presenter: OptionsPresenterProtocol!

    lazy var coordinator: OptionsCoordinatorProtocol = {
        OptionsCoordinator(
            parent: self.navigationController!
        )
    }()
    
    // MARK: - Private state
    
    private var tapRecognizer: UITapGestureRecognizer!

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = OptionsPresenter(
            view: self,
            repository: Storage.shared.repository,
            settings: LocalSettings.shared,
            coordinator: coordinator,
            calendar: CalendarHelper.shared,
            notificationManager: NotificationManager.shared
        )
        
        configureViews()
        presenter.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }

    // MARK: - OptionsView
    
    /// User tapped 4 times on the screen - used to enable dev mode
    var onSecretTap: (() -> Void)?

    /// Return UIViewController instance (so we can present and mail stuff from Presenter class)
    var viewController: UIViewController? {
        return self
    }
    
    /// Update page title
    func updateTitle(_ text: String) {
        title = text
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
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 4
        tableView.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        onSecretTap?()
    }
}
