//
//  OptionsDataSource.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

/// Overriding header and footer getters for diffable table data source
class OptionsDataSource: UITableViewDiffableDataSource<OptionsSection, OptionsCell> {

    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String?
    {
        let sec = self.snapshot().sectionIdentifiers[section]
        return sec.header
    }
    
    override func tableView(_ tableView: UITableView,
        titleForFooterInSection section: Int) -> String?
    {
        let sec = self.snapshot().sectionIdentifiers[section]
        return sec.footer
    }
}
