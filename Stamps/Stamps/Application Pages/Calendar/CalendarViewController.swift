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
    }
    
    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return calendar.numberOfMonths
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar.monthAt(section).numberOfWeeks
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return calendar.monthAt(section).label
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell") as! WeekCell
        
        let weekLabels = calendar.monthAt(indexPath.section).labelsForDaysInWeek(indexPath.row)
        let weekData = weekColorData(monthIdx: indexPath.section, weekIdx: indexPath.row)
        let awardData = awardColorData(monthIdx: indexPath.section, weekIdx: indexPath.row)
        
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
    
    // Helper method to go through seven days (some could be empty) and gather just
    // color data from stamps selected for these days
    func awardColorData(monthIdx: Int, weekIdx: Int) -> [UIColor] {
        var res = [UIColor]()
        
        let dateEnd = calendar.dateFromIndex(month: monthIdx, week: weekIdx, day: 6)
        if dateEnd != nil {
            // Update awards for Sunday
            AwardManager.shared.recalculateAwardsForWeek(dateEnd!)
            // Load them
            let awards = db.awardsForDateInterval(from: dateEnd!.byAddingDays(-6), to: dateEnd!)
            for award in awards {
                let goal = db.goalById(award.goalId)
                res.append(UIColor(hex: db.stampById(goal!.stampIds[0])!.color))
            }
        }
        
        return res
    }
}

// MARK: WeekCellDelegate - handling tap on the week day
extension CalendarViewController : WeekCellDelegate {
    
    func dayTapped(_ dayIdx: Int, indexPath: IndexPath) {
        
        // If tapped outside actual month date - bail out
        guard let date = calendar.dateFromIndex(month: indexPath.section, week: indexPath.row, day: dayIdx) else {
            return
        }

        // Load and configure day detail view controller
        let storyboard = UIStoryboard(name: "Calendar", bundle: nil)
        let dayDetail = storyboard.instantiateViewController(
                  withIdentifier: "dayDetail") as! DayViewController
        dayDetail.date = date
        
        // Use the popover presentation style for your view controller.
        dayDetail.modalPresentationStyle = .overFullScreen
        dayDetail.modalTransitionStyle = .coverVertical
        dayDetail.onDismiss = { (refresh) in
            if refresh {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
        // Present the view controller (in a popover).
        self.present(dayDetail, animated: true) {
          // The popover is visible.
        }
    }
}
