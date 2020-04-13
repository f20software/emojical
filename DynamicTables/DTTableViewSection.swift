//
//  DTTableViewSection.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

class DTTableViewSection: NSObject {
    
    let header: String?
    let footer: String?

    // Cell storage
    private var cells: [DTTableCell]
    
    // Weak reference to table view model
    weak var ownerTableViewModel: DTTableViewModel? {
        didSet {
            cells.forEach({ $0.ownerTableViewModel = self.ownerTableViewModel })
        }
    }

    init(headerTitle: String?, footerTitle: String? = nil) {
        self.header = headerTitle
        self.footer = footerTitle
        self.cells = []
    }
    
    @discardableResult func add(_ cell: DTTableCell) -> DTTableCell {
        cell.ownerSection = self
        cell.ownerTableViewModel = self.ownerTableViewModel
        cells.append(cell)
        return cell
    }

    func add(contentOf array: [DTTableCell]) {
        array.forEach({ $0.ownerSection = self; $0.ownerTableViewModel = self.ownerTableViewModel })
        cells.append(contentsOf: array)
    }

    func cell(at index: Int) -> DTTableCell? {
        guard index < cells.count else { return nil }
        return cells[index]
    }
    
    func index(of cell: DTTableCell) -> Int? {
        return cells.firstIndex(of: cell)
    }
    
    func insert(_ cell: DTTableCell, at i: Int) {
        cell.ownerSection = self
        cell.ownerTableViewModel = self.ownerTableViewModel
        cells.insert(cell, at: i)
    }
    
    func removeCell(at i: Int) {
        cells[i].ownerSection = nil
        cells.remove(at: i)
    }
    
    var visibleCellsCount: Int {
        return cells.filter({ $0.hidden == false }).count
    }
}
