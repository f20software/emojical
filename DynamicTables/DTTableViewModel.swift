//
//  DTTableViewModel.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 4/12/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class DTTableViewModel {
    
    var sections: [DTTableViewSection]
    var tableView: UITableView?
    
    init() {
        self.sections = []
    }
    
    func clear() {
        sections = []
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    func index(of section: DTTableViewSection?) -> Int? {
        guard let section = section else { return nil }
        return sections.firstIndex(of: section)
    }

    func cellModel(at indexPath: IndexPath) -> DTTableCell {
        return sections[indexPath.section].cell(at: indexPath.row)!
    }
    
    @discardableResult func add(_ section: DTTableViewSection) -> DTTableViewSection {
        section.ownerTableViewModel = self
        sections.append(section)
        return section
    }
    
}
