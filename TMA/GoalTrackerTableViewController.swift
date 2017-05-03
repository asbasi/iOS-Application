//
//  GoalTrackerTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 4/13/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift
import UserNotifications
import BEMCheckBox

class GoalTrackerAllocatedViewCell : UITableViewCell {
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
    
    var buttonAction: ((_ sender: GoalTrackerAllocatedViewCell) -> Void)?
    
    @IBAction func toggled(_ sender: Any) {
        self.buttonAction?(self)
    }
}

class GoalTrackerFreeViewCell: UITableViewCell {
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
}

class GoalTrackerTableViewController: UITableViewController {

    let realm = try! Realm()
    let eventStore = EKEventStore()
    
    var allocatedTimes = [[Event]]()
    var freeTimes = [[Event]]()
    
    private let ALLOCATED_TIMES = 0
    private let FREE_TIMES = 1
    
    var goal: Goal!
    
    private var selectedEvent: Event?
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var pageTitle: String?
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func segmentToggled(_ sender: Any) {
        self.populateFreeTimes()
        self.populateAllocatedTimes()
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = pageTitle
    }
    
    private func populateFreeTimes() {
        freeTimes = [[Event]]()
        
        for offset in 0...6 {
            
            var components = DateComponents()
            components.day = offset
            let date = Calendar.current.date(byAdding: components, to: Date())!
            
            var calEvents: [EKEvent] = []
            
            if EKEventStore.authorizationStatus(for: .event) == EKAuthorizationStatus.authorized {
                let calendars = eventStore.calendars(for: .event)
                calEvents = getCalendarEvents(forDate: date, fromCalendars: calendars)
            }
            else {
                
                let startDate = Calendar.current.startOfDay(for: date)
                
                var dateComponents = DateComponents()
                dateComponents.day = 1
                let endDate = Calendar.current.date(byAdding: dateComponents, to: startDate)
                
                let inAppEvents = self.realm.objects(Event.self).filter("date BETWEEN %@", [startDate, endDate]).sorted(byKeyPath: "date", ascending: true)
                
                for event in inAppEvents {
                    let item = EKEvent(eventStore: eventStore)
                    item.startDate = event.date
                    item.endDate = event.endDate
                    calEvents.append(item)
                }
            }
            
            let events = findFreeTimes(onDate: (offset == 0 ? date : Calendar.current.startOfDay(for: date)), withEvents: calEvents)
            
            if(events.count > 0) {
                freeTimes.append(events)
            }
        }

    }
    
    private func populateAllocatedTimes() {
        allocatedTimes = [[Event]]()
        
        // Get all events related to the course.
        let events = self.realm.objects(Event.self).filter("goal.course.quarter.current = true AND goal.title = '\(self.goal.title!)'").sorted(byKeyPath: "date", ascending: true)
        
        var allDates = [Date]()
        
        for event in events {
            let date = Calendar.current.startOfDay(for: event.date)
            
            if !allDates.contains(date) && date >= Calendar.current.startOfDay(for: Date()) {
                allDates.append(date)
            }
        }
        
        for dateBegin in allDates {
            var components = DateComponents()
            components.day = 1
            let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
            
            allocatedTimes.append(Array(events.filter("date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkCalendarAuthorizationStatus()
        
        self.populateFreeTimes()
        self.populateAllocatedTimes()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 11)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"

        // Just in case. Was getting some weird nil values when unwrapping.
        populateFreeTimes()
        populateAllocatedTimes()
        
        var date: Date!
        if segmentController.selectedSegmentIndex == ALLOCATED_TIMES {
            if allocatedTimes[section].count != 0 {
                date = self.allocatedTimes[section][0].date
            }
        }
        else {
            if freeTimes[section].count != 0 {
                date = self.freeTimes[section][0].date
            }
        }
        
        let strDate = formatter.string(from: date!)
        if Calendar.current.isDateInToday(date) {
            return "Today (\(strDate))"
        }
        else if Calendar.current.isDateInTomorrow(date) {
            return "Tommorow (\(strDate))"
        }

        return strDate
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if segmentController.selectedSegmentIndex == ALLOCATED_TIMES {
            return allocatedTimes.count
        }
        else {
            return freeTimes.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == ALLOCATED_TIMES {
            return allocatedTimes[section].count
        }
        else {
            return freeTimes[section].count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.segmentController.selectedSegmentIndex == self.ALLOCATED_TIMES {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerAllocatedCell", for: indexPath) as! GoalTrackerAllocatedViewCell
            
            let event = allocatedTimes[indexPath.section][indexPath.row]
            
            cell.title?.text = "Free"
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            cell.day?.text = dayFormatter.string(from: event.date )
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.timeZone = TimeZone.current
            
            if(event.duration == 24.0) {
                cell.time?.text = "All Day"
            }
            else {
                cell.time?.text = timeFormatter.string(from: event.date ) + " - " + timeFormatter.string(from: Date.getEndDate(fromStart: event.date, withDuration: event.duration))
            }
            
            cell.checkbox.on = event.checked
            cell.checkbox.boxType = BEMBoxType.square
            cell.checkbox.onAnimationType = BEMAnimationType.fill
            cell.buttonAction = { (_ sender: GoalTrackerAllocatedViewCell) -> Void in
                
                var path: IndexPath = self.tableView.indexPath(for: sender)!
                
                let event = self.allocatedTimes[path.section][path.row]
                
                if(event.checked) { // About to be unchecked.
                    if let log = event.log {
                        try! self.realm.write {
                            self.realm.delete(log)
                            event.log = nil
                        }
                    }
                }
                else { // About to be checked.
                    
                    let alert = UIAlertController(title: "Enter Time", message: "How much time (as a decimal number) did you spend studying?", preferredStyle: .alert)
                    
                    alert.addTextField { (textField) in
                        textField.keyboardType = .decimalPad
                        textField.text = "\(event.duration)"
                    }
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                        let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                        
                        if textField.text != "" {
                            let log = Log()
                            
                            log.title = event.title
                            log.duration = Float(textField.text!)!
                            log.date = event.date
                            log.course = event.course
                            log.type = event.type
                            
                            Helpers.DB_insert(obj: log)
                            
                            try! self.realm.write {
                                event.log = log
                            }
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                try! self.realm.write {
                    self.allocatedTimes[path.section][path.row].checked = !self.allocatedTimes[path.section][path.row].checked
                }
            }
            
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerFreeCell", for: indexPath) as! GoalTrackerFreeViewCell

            let event = freeTimes[indexPath.section][indexPath.row]
            
            cell.title?.text = "Free"
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            cell.day?.text = dayFormatter.string(from: event.date )
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.timeZone = TimeZone.current
            
            if(event.duration == 24.0) {
                cell.time?.text = "All Day"
            }
            else {
                cell.time?.text = timeFormatter.string(from: event.date ) + " - " + timeFormatter.string(from: Date.getEndDate(fromStart: event.date, withDuration: event.duration))
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = segmentController.selectedSegmentIndex == ALLOCATED_TIMES ? allocatedTimes[indexPath.section][indexPath.row] : freeTimes[indexPath.section][indexPath.row]
        
        self.performSegue(withIdentifier: "manageEvent", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.segmentController.selectedSegmentIndex == self.ALLOCATED_TIMES {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let event = self.allocatedTimes[index.section][index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(event.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                // Remove any pending notifications for the event.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.reminderID])
                
                if let id = event.calEventID {
                    deleteEventFromCalendar(withID: id)
                }
                
                try! self.realm.write {
                    
                    if self.segmentController.selectedSegmentIndex == self.ALLOCATED_TIMES {
                        self.allocatedTimes[index.section].remove(at: index.row)
                        
                        if self.allocatedTimes[index.section].count == 0 {
                            self.allocatedTimes.remove(at: index.section)
                        }
                    }
                    else {
                        self.freeTimes[index.section].remove(at: index.row)
                        
                        if self.freeTimes[index.section].count == 0 {
                            self.freeTimes.remove(at: index.section)
                        }
                    }
                    
                    if let log = event.log {
                        self.realm.delete(log)
                    }
                    
                    self.realm.delete(event)
                }
                
                self.tableView.reloadData()
            })
            optionMenu.addAction(deleteAction);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            })
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }//end delete
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            self.selectedEvent = self.allocatedTimes[index.section][index.row]
            
            self.performSegue(withIdentifier: "manageEvent", sender: nil)
        }
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "manageEvent" {
            
            let navigation: UINavigationController = segue.destination as! UINavigationController
            
            var manageEventTableViewController = ManageEventTableViewController.init()
            manageEventTableViewController = navigation.viewControllers[0] as! ManageEventTableViewController
            
            manageEventTableViewController.event = selectedEvent!
            manageEventTableViewController.goal = self.goal
            manageEventTableViewController.type = segmentController.selectedSegmentIndex == ALLOCATED_TIMES ? "alloc" : "free"
        }
    }
}
