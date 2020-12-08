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

    // MARK: - Outlets
    
    @IBOutlet weak var styleToggle: UIBarButtonItem!
    
    // MARK: - Private state
    
    private var calendar: CalendarHelper {
        return CalendarHelper.shared
    }
    
    private var repository: DataRepository {
        return Storage.shared.repository
    }
    
    private var model: [[CalendarCellData]] = []
    private var style: CalendarDataBuilder.Style = .compact

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a handler to react to user opening notification
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToToday), name: .navigateToToday, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAwards), name: .awardsAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAwards), name: .awardsDeleted, object: nil)

        // Since we're showing month header as the first cell in each section we want to hide
        // default header and footer views and hide separators so header and footers are not visible
        tableView.separatorColor = UIColor.clear
        
        prepareData()
        updateScroll()
    }
    
    // MARK: - Events
    
    @IBAction func expandToggled(_ sender: AnyObject) {
        styleToggle.title = style.action
        style = !style
        prepareData()
        updateScroll()
        tableView.reloadData()
    }

    // MARK: - UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section].count
    }

    // Minimize header and footer sizes
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard model.count > indexPath.section, model[indexPath.section].count > indexPath.row else {
            return UITableViewCell()
        }
        
        switch model[indexPath.section][indexPath.row] {
        case let .header(title, monthlyAwards, weeklyAwards):
            let cell = tableView.dequeueReusableCell(withIdentifier: "monthHeader") as! MonthHeaderView
            cell.configure(title: title, monthlyAwards: monthlyAwards, weeklyAwards: weeklyAwards)
            return cell
        case let .compactWeek(labels, data, awards):
            let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell") as! WeekCell
            cell.configure(labels, data: data, awards: awards, indexPath: indexPath)
            cell.delegate = self
            return cell
        case let .expandedWeek(labels, data, awards):
            let cell = tableView.dequeueReusableCell(withIdentifier: "expandedWeekCell") as! ExpandedWeekCell
            cell.configure(labels, data: data, awards: awards, indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }

    func showDayView(date: Date, indexPath: IndexPath) {
        // Load and configure day detail view controller
        let storyboard = UIStoryboard(name: "Calendar", bundle: nil)
        let dayDetail = storyboard.instantiateViewController(
                  withIdentifier: "dayDetail") as! DayViewController
        dayDetail.date = date
        
        // Use the popover presentation style for your view controller.
        dayDetail.modalPresentationStyle = .overFullScreen
        dayDetail.modalTransitionStyle = .coverVertical
        dayDetail.onDismiss = { [weak self] (wasUpdated) in
            guard wasUpdated == true else { return }
            guard let self = self else { return }
                
            // If it was today's date - post notification that today's entry was updated
            // it will be used by ReminderManager to update reminder notification
            if date.isToday {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    NotificationCenter.default.post(name: .todayStickersUpdated, object: nil)
                })
            }

            // Recalculate awards
            AwardManager.shared.recalculateAwards(date)
            self.prepareData()
            
            // Update row.
            self.tableView.reloadRows(at: self.rowsToBeRefreshed(indexPath), with: .fade)
        }
        
        // Present the view controller (in a popover).
        self.present(dayDetail, animated: true) {
            // The popover is visible.
        }
    }
    
    // MARK: - Private helpers
    
    private func prepareData() {
        model = CalendarDataBuilder(repository: repository, calendar: calendar).cells(forStyle: style)
    }
    
    private func updateScroll() {
        let indexPath: IndexPath? = {
            switch style {
            case .compact:
                return calendar.indexForDay(date: Date())?.0
            case .extended:
                return calendar.weekIndexForDay(date: Date()).flatMap({ IndexPath(row: 1, section: $0) })
//            case .today:
//                return nil
            }
        }()
        
        guard let target = indexPath else { return }
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: target, at: .middle, animated: false)
        }
    }
}

// MARK: - Notification handling
extension CalendarViewController {

    @objc func navigateToToday() {
        let today = Date()
        if let index = self.calendar.indexForDay(date: today) {
            showDayView(date: today, indexPath: index.0)
        }
    }
    
    // TODO: This method will be called when award is added or removed
    // Right now we just update monthly header for these awards, but we potentially need to add logic to
    // recognize weekly vs monthly awards and whether award was added or removed (with potentially different
    // animation)
    @objc func refreshAwards(notification: Notification) {
        guard let awards = notification.object as? [Award] else { return }
        prepareData()
        
        let cellsToRefresh: [IndexPath]? = {
            switch style {
            case .compact:
                // Refresh each month cell that award was added to.
                return awards.compactMap { award -> IndexPath? in
                    guard let (indexPath, _) = self.calendar.indexForDay(date: award.date)
                        else { return nil }
                    return IndexPath(row: 0, section: indexPath.section)
                }
            case .extended:
                // Refresh each week cell that award was added to.
                return awards.compactMap { award -> [IndexPath]? in
                    guard let index = self.calendar.weekIndexForDay(date: award.date)
                        else { return nil }
                    return [IndexPath(row: 0, section: index), IndexPath(row: 1, section: index)]
                }.flatMap { $0 }
//            case .today:
//                return nil
            }
        }()

        // Refresh cells with a short delay and play a sound
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            if let paths = cellsToRefresh {
                self.tableView.reloadRows(at: paths, with: .fade)
            } else {
                self.tableView.reloadData()
            }
        })
    }
}

// MARK: WeekCellDelegate - handling tap on the week day
extension CalendarViewController : WeekCellDelegate, ExpandedWeekCellDelegate {
    
    // After day stickers were edited we will refresh whole week that day is part of
    // Since week cells also include weekly awards and these awards are displayed on the right edge of the week
    // award view could belong to the next month (for example when editing stickers on 3/31/2020 we would
    // to upate week of 4/1/2020 since end of week for 3/31/2020 will fall into April
    // This method will return two IndexPath objects if such conditions were met
    func rowsToBeRefreshed(_ row: IndexPath) -> [IndexPath] {
        switch style {
        case .extended:
            // Need to refresh the whole month in case awards have been added to/removed from other weeks.
            let editedWeek = calendar.currentWeeks[row.section]
            let rows = calendar.currentWeeks
                .enumerated()
                .filter({ $0.1.year == editedWeek.year && $0.1.month == editedWeek.month })
                .flatMap { [IndexPath(row: 0, section: $0.offset), IndexPath(row: 1, section: $0.offset)] }
            return rows
        case .compact:
            let endOfWeek = calendar.dateFromIndex(month: row.section, week: row.row-1, day: 6)
            // If end of week is not part of current month and we still have sections on the celendar
            // include first week of next month to be refreshed too
            if endOfWeek == nil && row.section < tableView.numberOfSections {
                let row2 = IndexPath(row: 1, section: row.section+1)
                return [row, row2]
            }
            return [row]
//        case .today:
//            return []
        }
    }

    func dayTapped(_ dayIdx: Int, indexPath: IndexPath) {
        switch style {
        case .extended:
            guard let date = calendar.currentWeeks[indexPath.section].date(forWeekday: dayIdx) else {
                return
            }
            
            showDayView(date: date, indexPath: indexPath)
        case .compact:
            // If tapped outside actual month date - bail out
            guard let date = calendar.dateFromIndex(month: indexPath.section, week: indexPath.row-1, day: dayIdx) else {
                return
            }
            
            showDayView(date: date, indexPath: indexPath)
//        case .today:
//            return 
        }
    }
}
