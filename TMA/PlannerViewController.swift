
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
        
        let alert = UIAlertController(title: "Enter Time", message: "How much time in hour did you do?", preferredStyle: UIAlertControllerStyle.alert)
        
        let logAction = UIAlertAction(title: "Log", style: .default, handler: {alert -> Void in
            //add a log here
            
            self.buttonAction?(self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {alert -> Void in
            
        })
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Time in hours"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(logAction)
        alert.addAction(cancelAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
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
        self.events = allTypesOfEvents[segmentController.selectedSegmentIndex]
        self.populateSegments()
        bottomMessage = "You don't have any \(segmentMessage[segmentController.selectedSegmentIndex]) events. All your \(segmentMessage[segmentController.selectedSegmentIndex]) events will show up here."
        
        self.myTableView.reloadData()
    }
    
    @IBAction func addingEvent(_ sender: Any) {
        if self.realm.objects(Course.self).filter("quarter.current = true").count == 0 {
            let alert = UIAlertController(title: "No Courses", message: "You must add a course to the current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            self.performSegue(withIdentifier: "addEvent", sender: nil)
        }
    }
    
    func populateSegments()
    {
        let cal = Calendar(identifier: .gregorian)
        
        let activeEvents = self.realm.objects(Event.self).filter("checked = false AND course.quarter.current = true").sorted(byKeyPath: "date", ascending: true)
        let finishedEvents = self.realm.objects(Event.self).filter("checked = true AND course.quarter.current = true").sorted(byKeyPath: "date", ascending: true)
        let allEvents = self.realm.objects(Event.self).filter("course.quarter.current = true").sorted(byKeyPath: "date", ascending: true)
        let rawEvents = [activeEvents, finishedEvents, allEvents]
        
        self.segmentController.setTitle("Active (\(activeEvents.count))", forSegmentAt: 0)
        self.segmentController.setTitle("Finished (\(finishedEvents.count))", forSegmentAt: 1)
        self.segmentController.setTitle("All (\(allEvents.count))", forSegmentAt: 2)
        
        for segment in 0...2
        {
            var events = [[Event]]()
            var allDates = [Date]()
            for event in rawEvents[segment]
            {
                let date = cal.startOfDay(for: event.date as Date)
                if !allDates.contains(date)  {
                    allDates.append(date)
                }
            }
            
            for dateBegin in allDates
            {
                var components = DateComponents()
                components.day = 1
                components.second = -1
                let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
                
                if(segment == 0) // Active
                {
                    events.append(Array(self.realm.objects(Event.self).filter("checked = false AND course.quarter.current = true AND date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
                }
                else if(segment == 1) // Finished
                {
                    events.append(Array(self.realm.objects(Event.self).filter("checked = true AND course.quarter.current = true AND date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
                }
                else if(segment == 2) // All
                {
                    events.append(Array(self.realm.objects(Event.self).filter("course.quarter.current = true AND date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
                }
            }
            
            self.allTypesOfEvents[segment] = events
        }
        
        self.events = self.allTypesOfEvents[segmentController.selectedSegmentIndex]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateSegments()
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        footerView.backgroundColor = UIColor.clear
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView,  heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "PlannerCell", for: indexPath) as! PlannerViewCell
        
        let event = self.events[indexPath.section][indexPath.row]
        let date = event.date as Date
        
        cell.title?.text = event.title
        cell.checkbox.on = event.checked
        cell.course?.text = event.course.identifier
        
        cell.color.backgroundColor = colorMappings[event.course.color]
        cell.color.layer.cornerRadius = 4.0
        cell.color.clipsToBounds = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        cell.time?.text = formatter.string(from: date)
        
        cell.checkbox.boxType = BEMBoxType.square
        cell.checkbox.onAnimationType = BEMAnimationType.fill
        cell.buttonAction = { (_ sender: PlannerViewCell) -> Void in
            
            var path: IndexPath = self.myTableView.indexPath(for: sender)!
            
            let event = self.events[path.section][path.row]
            
            if !event.checked {
                // About to check off the event so remove any pending notifications.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.reminderID])
            }
            else {
                if let date = event.reminderDate {
                    // Event is getting unchecked so schedule another notification.
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.scheduleNotifcation(at: date, title: event.title, body: "Reminder!", identifier: event.reminderID)
                }
            }
            
            try! self.realm.write {
                self.events[path.section][path.row].checked = !self.events[path.section][path.row].checked
            }
            
            self.events[path.section].remove(at: path.row)
            if self.events[path.section].count == 0 {
                self.events.remove(at: path.section)
            }
            
            self.animatedRemove(at: path, type: "checkboxToggle")
        }
        
        if Calendar.current.isDateInToday(date) // Today.
        {
            cell.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
        }
        else if NSDate().compare(date) == .orderedDescending // Before Today.
        {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.1)
        }
        else // After Today.
        {
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventToEdit = self.events[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "showEvent", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let event = self.events[index.section][index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(event.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                // Remove any pending notifications for the event.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.reminderID])
                deleteEventFromCalendar(withID: event.calEventID)
                
                try! self.realm.write {
                    self.events[index.section].remove(at: index.row)
                    if self.events[index.section].count == 0 {
                        self.events.remove(at: index.section)
                    }

                    self.realm.delete(event)
                }
                
                self.animatedRemove(at: index, type: "delete")
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
        else if segue.identifier! == "showEvent" {
            eventAddViewController.operation = "show"
            eventAddViewController.event = eventToEdit!
        }
    }
}
