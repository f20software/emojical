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
        
        // Add a handler to react to user opening notification
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToToday), name: .navigateToToday, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let (indexPath, _) = calendar.indexForDay(date: Date()) else { return }
        
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return calendar.numberOfMonths
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar.monthAt(section).numberOfWeeks
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "monthHeader") as! MonthHeaderView
        let header = tableView.dequeueReusableCell(withIdentifier: "monthHeader") as! MonthHeaderView
        header.title.text = calendar.monthAt(section).label
        header.badges.badges = monthAwardColors(monthIdx: section)
        return header.contentView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell") as! WeekCell
        
        let weekLabels = calendar.monthAt(indexPath.section).labelsForDaysInWeek(indexPath.row)
        let weekData = weekColorData(monthIdx: indexPath.section, weekIdx: indexPath.row)
        let awardData = weekAwardColors(monthIdx: indexPath.section, weekIdx: indexPath.row)
        
        cell.loadData(weekLabels, data: weekData, awards: awardData, indexPath: indexPath)
        cell.delegate = self
        return cell
    }

    // Helper method to go through seven days (some could be empty) and gather just
    // color data from stamps selected for these days
    func weekColorData(monthIdx: Int, weekIdx: Int) -> [[UIColor]] {
        var res = [[UIColor]]()
        for i in 0..<7 {
            let date = calendar.dateFromIndex(month: monthIdx, week: weekIdx, day: i)
            // Invalid date? Bail our early
            if date == nil {
                res.append([])
                continue
            }

            var colors = [UIColor]()
            for stamp in db.stampsIdsForDay(date!) {
                colors.append(UIColor(hex: db.stampById(stamp)!.color))
            }
            
            res.append(colors)
        }
        
        return res
    }
    
    // Helper method to go through a week of awards and gather just colors
    func weekAwardColors(monthIdx: Int, weekIdx: Int) -> [UIColor] {
        var res = [UIColor]()
        let dateEnd = calendar.dateFromIndex(month: monthIdx, week: weekIdx, day: 6)

        let awards = db.weeklyAwardsForWeek(endingOn: dateEnd)
        for award in awards {
            if let color = db.colorForAward(award) {
                res.append(color)
            }
        }
        
        return res
    }

    // Helper method to go through a monthly awards and gather just colors
    func monthAwardColors(monthIdx: Int) -> [UIColor] {
        var res = [UIColor]()
        let month = calendar.monthAt(monthIdx)
        let date = Date(year: month.year, month: month.month)

        let awards = db.monthlyAwardsForMonth(date: date)
        for award in awards {
            if let color = db.colorForAward(award) {
                res.append(color)
            }
        }

        return res
    }
    
    @objc func navigateToToday() {
        showDayView(date: Date())
    }
    
    func showDayView(date: Date) {
        
        // Load and configure day detail view controller
        let storyboard = UIStoryboard(name: "Calendar", bundle: nil)
        let dayDetail = storyboard.instantiateViewController(
                  withIdentifier: "dayDetail") as! DayViewController
        dayDetail.date = date
        
        // Use the popover presentation style for your view controller.
        dayDetail.modalPresentationStyle = .overFullScreen
        dayDetail.modalTransitionStyle = .coverVertical
        dayDetail.onDismiss = { (wasUpdated) in
            guard wasUpdated == true else { return }
                
            // If it was today's date - post notification that today's entry was updated
            // it will be used by ReminderManager to update reminder notification
            if date.isToday {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    NotificationCenter.default.post(name: .todayStickersUpdated, object: nil)
                })
            }

            AwardManager.shared.recalculateAwardsForWeek(date)
            let monthNeedUpdate = AwardManager.shared.recalculateAwardsForMonth(date)
            
            guard let (indexPath, _) = self.calendar.indexForDay(date: date) else { return }
            
            if monthNeedUpdate {
                self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section, indexPath.section+1), with: .fade)
            }
            else {
                self.tableView.reloadRows(at: self.rowsToBeRefreshed(indexPath), with: .fade)
            }
        }
        
        // Present the view controller (in a popover).
        self.present(dayDetail, animated: true) {
          // The popover is visible.
        }
    }
    
}


// MARK: WeekCellDelegate - handling tap on the week day
extension CalendarViewController : WeekCellDelegate {
    
    func rowsToBeRefreshed(_ row: IndexPath) -> [IndexPath] {
        let dateEnd = calendar.dateFromIndex(month: row.section, week: row.row, day: 6)
        if dateEnd == nil {
            let row2 = IndexPath(row: 0, section: row.section+1)
            return [row, row2]
        }
        return [row]
    }
    
    func dayTapped(_ dayIdx: Int, indexPath: IndexPath) {
        // If tapped outside actual month date - bail out
        guard let date = calendar.dateFromIndex(month: indexPath.section, week: indexPath.row, day: dayIdx) else {
            return
        }
        
        showDayView(date: date)
    }
}
