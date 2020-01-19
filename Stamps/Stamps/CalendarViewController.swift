//
//  FirstViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class CalendarViewController: UITableViewController {

    var data = StampsData.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.numberOfMonth
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.numberOfWeeks(month: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.textForMonth(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell") as! WeekCell
        cell.loadData(data.textForWeek(month: indexPath.section, week: indexPath.row))
        return cell
    }

}

