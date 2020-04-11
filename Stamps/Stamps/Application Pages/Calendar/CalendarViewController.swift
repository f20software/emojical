//
//  CalendarViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAwards), name: .awardsAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAwards), name: .awardsDeleted, object: nil)

        // Since we're showing month header as the first cell in each section we want to hide
        // default header and footer views and hide separators so header and footers are not visible
        tableView.separatorColor = UIColor.clear
        
        guard let (indexPath, _) = calendar.indexForDay(date: Date()) else { return }

        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }

    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return calendar.numberOfMonths
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Each month will contain one extra cell at the top to display month header
        return calendar.monthAt(section).numberOfWeeks + 1
    }

    // Minimize header and footer sizes
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let month = indexPath.section
        // First row is month header
        let week = indexPath.row - 1
        
        // Is this month header?
        if week < 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "monthHeader") as! MonthHeaderView
            let monthlyAwardColors = monthAwardColors(monthIdx: month, period: .month)
            let weeklyAwardColors = monthAwardColors(monthIdx: month, period: .week)
            cell.configure(title: calendar.monthAt(month).label, monthlyAwards: monthlyAwardColors, weeklyAwards: weeklyAwardColors)
            return cell
        
        // Everything else is regular weekly cells
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell") as! WeekCell
            let weekLabels = calendar.monthAt(month).labelsForDaysInWeek(week)
            let weekData = weekColorData(monthIdx: month, weekIdx: week)
            let awardData = weekAwardColors(monthIdx: month, weekIdx: week)
            cell.configure(weekLabels, data: weekData, awards: awardData, indexPath: indexPath)
            cell.delegate = self
            return cell
        }
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

            // Recalculate awards
            AwardManager.shared.recalculateAwards(date)
            
            // Update cell (or cells) in which edited day was shown
            guard let (indexPath, _) = self.calendar.indexForDay(date: date) else { return }
            self.tableView.reloadRows(at: self.rowsToBeRefreshed(indexPath), with: .left)
        }
        
        // Present the view controller (in a popover).
        self.present(dayDetail, animated: true) {
          // The popover is visible.
        }
    }
}

// MARK: - Notification handling
extension CalendarViewController {

    @objc func navigateToToday() {
        showDayView(date: Date())
    }
    
    // TODO: This method will be called when award is added or removed
    // Right now we just update monthly header for these awards, but we potentially need to add logic to
    // recognize weekly vs monthly awards and whether award was added or removed (with potentially different
    // animation)
    @objc func refreshAwards(notification: Notification) {
        guard let awards = notification.object as? [Award] else { return }

        var cellsToRefresh = [IndexPath]()
        for award in awards {
            let date = Date(yyyyMmDd: award.date)
            guard let (indexPath, _) = self.calendar.indexForDay(date: date) else { return }
            cellsToRefresh.append(IndexPath(row: 0, section: indexPath.section))
        }

        // Refresh cells with a short delay and play a sound
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.tableView.reloadRows(at: cellsToRefresh, with: .right)
        })
    }
}

// MARK: - Data extraction
//
// Helper methods to get various awards data and organize it in an easy way to
// consume by table cell views
extension CalendarViewController {

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
    func monthAwardColors(monthIdx: Int, period: Goal.Period) -> [UIColor] {
        var res = [UIColor]()
        let month = calendar.monthAt(monthIdx)
        let date = Date(year: month.year, month: month.month)

        let awards = period == .month ? db.monthlyAwardsForMonth(date: date) : db.weeklyAwardsForMonth(date: date)
        for award in awards {
            if let color = db.colorForAward(award) {
                res.append(color)
            }
        }

        return res
    }

}

// MARK: WeekCellDelegate - handling tap on the week day
extension CalendarViewController : WeekCellDelegate {
    
    // After day stickers were edited we will refresh whole week that day is part of
    // Since week cells also include weekly awards and these awards are displayed on the right edge of the week
    // award view could belong to the next month (for example when editing stickers on 3/31/2020 we would
    // to upate week of 4/1/2020 since end of week for 3/31/2020 will fall into April
    // This method will return two IndexPath objects if such conditions were met
    func rowsToBeRefreshed(_ row: IndexPath) -> [IndexPath] {
        let endOfWeek = calendar.dateFromIndex(month: row.section, week: row.row-1, day: 6)
        // If end of week is not part of current month and we still have sections on the celendar
        // include first week of next month to be refreshed too
        if endOfWeek == nil && row.section < tableView.numberOfSections {
            let row2 = IndexPath(row: 1, section: row.section+1)
            return [row, row2]
        }
        return [row]
    }

    func dayTapped(_ dayIdx: Int, indexPath: IndexPath) {
        // If tapped outside actual month date - bail out
        guard let date = calendar.dateFromIndex(month: indexPath.section, week: indexPath.row-1, day: dayIdx) else {
            return
        }
        
        showDayView(date: date)
    }
}
