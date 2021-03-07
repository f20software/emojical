//
//  BaseTableViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    var dataSource: OptionsDataSource!

    // MARK: - Data source
    
    var sections = [Section]()

    func configureTableView() {
        dataSource = OptionsDataSource(
            tableView: tableView,
            cellProvider: { [weak self] (tableView, path, model) -> UITableViewCell? in
                self?.cell(for: path, model: model, tableView: tableView)
            }
        )
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.backgroundColor = Theme.main.colors.background
    }
}

// MARK: - TableView support

extension BaseTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath) as? NavigateCell {
            cell.onSelected?()
        } else if let cell = tableView.cellForRow(at: indexPath) as? ButtonCell {
            cell.onButtonTapped?()
        } else if let cell = tableView.cellForRow(at: indexPath) as? StickerStyleCell {
            cell.toggleValue()
        }
    }
    
    private func cell(for path: IndexPath, model: Cell, tableView: UITableView) -> UITableViewCell? {
        switch model {
        case .text(let text, let value):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.textCell)
                as? TextCell else { return UITableViewCell() }
            cell.configure(for: text, value: value)
            return cell
            
        case .button(let text, let callback):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.buttonCell)
                as? ButtonCell else { return UITableViewCell() }
            cell.configure(for: text)
            cell.onButtonTapped = callback
            return cell
            
        case .stickerStyle(let text, let sticker, let style, let callback):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.stickerStyleCell)
                as? StickerStyleCell else { return UITableViewCell() }
            cell.configure(for: text, sticker: sticker, style: style)
            cell.onValueChanged = callback
            return cell
            
        case .navigate(let text, let callback):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.navigationCell)
                as? NavigateCell else { return UITableViewCell() }
            cell.configure(for: text)
            cell.onSelected = callback
            return cell

        case .`switch`(let text, let value, let callback):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Specs.Cells.switchCell)
                as? SwitchCell else { return UITableViewCell() }
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
        
        /// Simple text cell identifier
        static let textCell = "textCell"
        
        /// Button cell identifier
        static let buttonCell = "buttonCell"
        
        /// Sticker style cell identifier
        static let stickerStyleCell = "stickerStyleCell"

        /// Switch cell identifier
        static let switchCell = "switchCell"

        /// Navigation cell identifier
        static let navigationCell = "navigationCell"
    }
}
