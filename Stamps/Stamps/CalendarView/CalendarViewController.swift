//
//  CalendarViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class CalendarViewController: UITableViewController {

    var calendar: CalenderHelper {
        return CalenderHelper.shared
    }
    
    var db: DataSource {
        return DataSource.shared
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return calendar.numberOfMonths
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar.numberOfWeeksIn(month: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return calendar.textForMonth(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell") as! WeekCell
        
        let weekLabels = calendar.textForWeek(month: indexPath.section, week: indexPath.row)
        var weekData = [[UIColor]]()
        
        for i in 0..<7 {
            let date = calendar.indexToDate(monthIdx: indexPath.section, weekIdx: indexPath.row, dayIdx: i)
            if date != nil {
                let stamps = db.stampsForDay(date!)
                var colors = [UIColor]()
                
                if stamps != nil {
                    for stamp in stamps! {
                        colors.append(db.stampById(stamp)!.color)
                    }
                }
                
                weekData.append(colors)
            }
            else {
                weekData.append([UIColor]())
            }
        }
        
        
        cell.loadData(weekLabels, data: weekData, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
}

extension CalendarViewController : WeekCellDelegate {
    
    func dayTapped(_ dayIdx: Int, indexPath: IndexPath) {
        let date = calendar.indexToDate(monthIdx: indexPath.section, weekIdx: indexPath.row, dayIdx: dayIdx)
        if date != nil {

            // Load and configure day detail view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let dayDetail = storyboard.instantiateViewController(
                      withIdentifier: "dayDetail") as! DayViewController
            dayDetail.date = date
            
            // Use the popover presentation style for your view controller.
            dayDetail.modalPresentationStyle = .overFullScreen
            dayDetail.modalTransitionStyle = .coverVertical
            dayDetail.onDismiss = { (Bool) in
                self.tableView.reloadData()
            }
            
            // Present the view controller (in a popover).
            self.present(dayDetail, animated: true) {
              // The popover is visible.
            }
        }
    }
}
