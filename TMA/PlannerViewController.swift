    
//
//  PlannerTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 2/10/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift
import BEMCheckBox
import UserNotifications
import EventKit

class PlannerViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var color: UIImageView!
    
    var buttonAction: ((_ sender: PlannerViewCell) -> Void)?
    
    @IBAction func checkboxToggled(_ sender: AnyObject) {
        self.buttonAction?(self)
    }
    
    func setUI(event: Event) {
        self.title?.text = event.title
        self.checkbox.on = event.checked
        self.course?.text = ""
        
        if let course = event.course { // not all events have a course (some are free times)
            self.course?.text = course.identifier
            
            self.color.backgroundColor = colorMappings[course.color]
            self.color.layer.cornerRadius = 4.0
            self.color.clipsToBounds = true
        }

        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        if(event.duration == 24.0) {
            self.time?.text = "All Day"
        }
        else {
            self.time?.text = formatter.string(from: event.date ) + " - " + formatter.string(from: Date.getEndDate(fromStart: event.date, withDuration: event.duration))
        }

        
        self.checkbox.boxType = BEMBoxType.square
        self.checkbox.onAnimationType = BEMAnimationType.fill
        
        
        self.checkbox.isHidden = false
        if event.type == SCHEDULE_EVENT || event.type == FREE_TIME_EVENT {
            self.checkbox.isHidden = true
        }
        
        if event.type == FREE_TIME_EVENT
        {
            self.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
        }
        else if event.type == SCHEDULE_EVENT
        {
            self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
        }
        else // After Today.
        {
            self.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.1)
        }
    }
}

class PlannerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let eventStore = EKEventStore()
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    
    let realm = try! Realm()
    
    var eventToEdit: Event!
    var events = [[Event]]()
    
    var allTypesOfEvents = [[[Event]](), [[Event]](), [[Event]]()] //0: Active, 1: Finished, 2: All
    
    let segmentMessage: [String] = ["active", "finished", "scheduled"]
    let image = UIImage(named: "notebook")!
    let topMessage = "Planner"
    var bottomMessage: String = "You don't have any active events. All your active events will show up here."
    
    @IBAction func segmentChanged(_ sender: Any) {
        //self.events = allTypesOfEvents[segmentController.selectedSegmentIndex]
        self.populateSegments()
        bottomMessage = "You don't have any \(segmentMessage[segmentController.selectedSegmentIndex]) events. All your \(segmentMessage[segmentController.selectedSegmentIndex]) events will show up here."
        
        self.myTableView.reloadData()
    }
    
    private func verify() {
        let currentQuarters = self.realm.objects(Quarter.self).filter("current = true")
        if currentQuarters.count != 1 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            let alert = UIAlertController(title: "Current Quarter Error", message: "You must have one current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let currentQuarter = currentQuarters[0]
            let courses = self.realm.objects(Course.self).filter("quarter.title = '\(currentQuarter.title!)'")
            
            if courses.count == 0 {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                let alert = UIAlertController(title: "No Courses Error", message: "You must have at least one course in the current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    
    @IBAction func addingEvent(_ sender: Any) {
        self.performSegue(withIdentifier: "addEvent", sender: nil)
    }
    
    func populateSegments()
    {
        let cal = Calendar(identifier: .gregorian)
        
        let allEvents = self.realm.objects(Event.self).filter("course.quarter.current = true").sorted(byKeyPath: "date", ascending: true)
        
        let activeEvents = allEvents.filter("checked = false").sorted(byKeyPath: "date", ascending: true)
        let finishedEvents = allEvents.filter("checked = true").sorted(byKeyPath: "date", ascending: true)
        
        let segmentEventsArray = [activeEvents, finishedEvents, allEvents]
        
        self.segmentController.setTitle("Active (\(activeEvents.filter("type != \(SCHEDULE_EVENT) AND type != \(FREE_TIME_EVENT)").count))", forSegmentAt: 0)
        self.segmentController.setTitle("Finished (\(finishedEvents.filter("type != \(SCHEDULE_EVENT) AND type != \(FREE_TIME_EVENT)").count))", forSegmentAt: 1)
        self.segmentController.setTitle("Active (\(allEvents.filter("type != \(SCHEDULE_EVENT) AND type != \(FREE_TIME_EVENT)").count))", forSegmentAt: 2)
        
        var components = DateComponents()
        components.day = 1
        
        let todayDate =  cal.startOfDay(for: Date())
        
        for segment in 0...2
        {
            self.allTypesOfEvents[segment] = [[Event]]()
            var allDates = [Date]()
            
            var quarter: Quarter? = nil
            let quarters = self.realm.objects(Quarter.self).filter("current = true")
            if quarters.count != 0 {
                quarter = quarters.first
            }
            
            if quarter != nil {
                var dateBegin = Calendar.current.startOfDay(for: quarter!.startDate)
                let dateEnd = Calendar.current.startOfDay(for: quarter!.endDate)
                
                while(dateBegin <= dateEnd) {
                    allDates.append(dateBegin)
                    dateBegin = Calendar.current.date(byAdding: components, to: dateBegin)!
                }
            }
            else {
                for event in segmentEventsArray[segment]
                {
                    let date = cal.startOfDay(for: event.date as Date)
                    if !allDates.contains(date)  {
                        allDates.append(date)
                    }
                }
            }
            
            for dateBegin in allDates
            {
                let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
                
                
                var plannedEvents: [Event] = []
                
                if segment != 1 && dateBegin >= todayDate { //only show scheduled events in all events segment and when its today or the next 7 days
                    plannedEvents = Array(segmentEventsArray[segment].filter("date BETWEEN %@", [dateBegin,dateEnd]))
                }
                else {
                    plannedEvents = Array(segmentEventsArray[segment].filter("type != \(SCHEDULE_EVENT) AND date BETWEEN %@", [dateBegin,dateEnd]))
                }
                
                /********************** GET FREE TIMES *****************/
                
                var freeTimes: [Event] = []
                
                if(dateBegin >= todayDate && segment != 1) {
                    var calEvents: [EKEvent] = []
                    
                    if EKEventStore.authorizationStatus(for: .event) == EKAuthorizationStatus.authorized {
                        let calendars = eventStore.calendars(for: .event)
                        calEvents = getCalendarEvents(forDate: dateBegin, fromCalendars: calendars)
                    }
                    else {
                        var dateComponents = DateComponents()
                        dateComponents.day = 1
                        let endDate = Calendar.current.date(byAdding: dateComponents, to: dateBegin)
                        
                        let inAppEvents = self.realm.objects(Event.self).filter("date BETWEEN %@", [dateBegin, endDate]).sorted(byKeyPath: "date", ascending: true)
                        
                        for event in inAppEvents {
                            let item = EKEvent(eventStore: eventStore)
                            item.startDate = event.date
                            item.endDate = event.endDate
                            calEvents.append(item)
                        }
                    }
                    freeTimes = findFreeTimes(onDate: (Calendar.current.isDateInToday(dateBegin) ? Date() : dateBegin), withEvents: calEvents)
                }
                
                let allEvents = (freeTimes + plannedEvents).sorted(by: { $0.date < $1.date })
                
                self.allTypesOfEvents[segment].append(allEvents)
                
                let last_element = self.allTypesOfEvents[segment][self.allTypesOfEvents[segment].count - 1]
                if last_element.count == 0 {
                    self.allTypesOfEvents[segment].removeLast()
                }
            }
        }
        
        self.events = self.allTypesOfEvents[segmentController.selectedSegmentIndex]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateSegments()
        verify()
        checkCalendarAuthorizationStatus()
        
        self.myTableView.reloadData()
        
        // Scrolls down to the current date.
        var section: Int = 0
        for event in self.events {
            if Calendar.current.isDateInToday(event[0].date!) {
                self.myTableView.scrollToRow(at: IndexPath(row: 0, section: section), at: UITableViewScrollPosition.top, animated: true)
            }
            section += 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myTableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 11)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //        "Today (Monday, January 23rd)"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"
        
        let date = self.events[section][0].date! as Date
        let strDate = formatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return "Today (\(strDate))"
        }
        else if Calendar.current.isDateInTomorrow(date) {
            return "Tommorow (\(strDate))"
        }
        else {
            return strDate
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.events.count > 0 {
            self.myTableView.backgroundView = nil
            self.myTableView.separatorStyle = .singleLine
            
            return self.events.count
        }
        
        self.myTableView.backgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
        self.myTableView.separatorStyle = .none
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events[section].count
    }
    
    func animatedRemove(at path: IndexPath, type operation: String)
    {
        // The if statement is required to properly handle the "all" segment.
        if(operation != "checkboxToggle" || self.segmentController.selectedSegmentIndex != 2) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.myTableView.beginUpdates()
                if(self.events.count > 0 && self.events.count - 1 >= path.section && self.myTableView.numberOfRows(inSection: path.section) > 1)
                {
                    self.myTableView.deleteRows(at: [path], with: UITableViewRowAnimation.fade)
                }
                else
                {
                    self.myTableView.deleteSections(IndexSet(integer: path.section), with: UITableViewRowAnimation.fade)
                }
                self.myTableView.endUpdates()
            })
        }
        
        self.populateSegments()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.events[indexPath.section][indexPath.row].type != SCHEDULE_EVENT && self.events[indexPath.section][indexPath.row].type != FREE_TIME_EVENT {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "PlannerCell", for: indexPath) as! PlannerViewCell
        
        let event = self.events[indexPath.section][indexPath.row]
        
        cell.buttonAction = { (_ sender: PlannerViewCell) -> Void in
            
            var path: IndexPath = self.myTableView.indexPath(for: sender)!
            
            let event = self.events[path.section][path.row]
            
            if(event.checked) { // About to be unchecked.
                
                if let date = event.reminderDate {
                    // Event is getting unchecked so schedule another notification.
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.scheduleNotifcation(at: date, title: event.title, body: "Reminder!", identifier: event.reminderID)
                }
                
                try! self.realm.write {
                    event.durationStudied = 0.0
                }
            }
            else { // About to be checked.
                self.present(Helpers.getLogAlert(event: event, realm: self.realm), animated: true, completion: nil)
            }
            
            // About to check off the event so remove any pending notifications.
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.reminderID])
            
            try! self.realm.write {
                self.events[path.section][path.row].checked = !self.events[path.section][path.row].checked
            }
            
            self.events[path.section].remove(at: path.row)
            if self.events[path.section].count == 0 {
                self.events.remove(at: path.section)
            }
            
            self.animatedRemove(at: path, type: "checkboxToggle")
        }
        
        cell.setUI(event: event)
        
        return cell
    }
    
    // a row has been selected in table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.section][indexPath.row]
        
        self.eventToEdit = event
        
        if(event.type == SCHEDULE_EVENT) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else if (event.type == FREE_TIME_EVENT) {
            self.performSegue(withIdentifier: "manageFreeTime", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "editEvent", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let event = self.events[index.section][index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(event.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                // Remove any pending notifications for the event.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.reminderID])
                
                if let id = event.calEventID {
                    deleteEventFromCalendar(withID: id)
                }
                
                try! self.realm.write {
                    
                    self.events[index.section].remove(at: index.row)
                    if self.events[index.section].count == 0 {
                        self.events.remove(at: index.section)
                    }
                    
                    event.durationStudied = 0.0
                    
                    self.realm.delete(event)
                }
                
                //self.animatedRemove(at: index, type: "delete")
                self.populateSegments()
                self.myTableView.reloadData()
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
            
            self.eventToEdit = self.events[index.section][index.row]
            
            self.performSegue(withIdentifier: "editEvent", sender: nil)
        }
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier! == "toggle" {
            return
        }
        
        let navigation: UINavigationController = segue.destination as! UINavigationController
        
        var eventAddViewController = PlannerAddTableViewController.init()
        eventAddViewController = navigation.viewControllers[0] as! PlannerAddTableViewController
        
        if segue.identifier! == "addEvent" {
            eventAddViewController.operation = "add"
        }
        else if segue.identifier! == "editEvent" {
            eventAddViewController.operation = "edit"
            eventAddViewController.event = eventToEdit!
        }
        else if segue.identifier! == "manageFreeTime" {
            eventAddViewController.operation = "manage"
            eventAddViewController.event = eventToEdit!
        }
    }
}
