//
//  ManageEventTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 4/22/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ManageEventTableViewController: UITableViewController {

    let realm = try! Realm()
    
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var event: Event!
    var goal: Goal!
    var type: String! // "alloc" : "free"
    var dateFormatter = DateFormatter()
    
    
    @IBAction func setStartDate(_ sender: Any) {
        startDateLabel.text = dateFormatter.string(from: startDatePicker.date)
    }
    
    @IBAction func setEndDate(_ sender: Any) {
        endDateLabel.text = dateFormatter.string(from: endDatePicker.date)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        if type == "free" {
            event.date = startDatePicker.date
            event.endDate = endDatePicker.date
            event.duration = Date.getDifference(initial: event.date, final: event.endDate)
            event.reminderID = UUID().uuidString
            event.reminderDate = event.date
            
            event.title = goal.title + " (\(eventType[goal.type]))"
            event.course = goal.course
            event.type = goal.type
            event.goal = goal
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.scheduleNotifcation(at: event!.reminderDate!, title: event!.title, body: "Reminder!", identifier: event!.reminderID)
            
            if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                
                event.calEventID = addEventToCalendar(event: event, toCalendar: calendarIdentifier as! String)
            }
            
            Helpers.DB_insert(obj: event)
        }
        else
        {
            try! self.realm.write {
                event.date = startDatePicker.date
                event.endDate = endDatePicker.date
                event.duration = Date.getDifference(initial: event.date, final: event.endDate)
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event!.reminderID])
                
                if let date = event.reminderDate {
                    if date >= Date() {
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.scheduleNotifcation(at: date, title: event!.title, body: "Reminder!", identifier: event!.reminderID)
                    }
                    else {
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.scheduleNotifcation(at: event.date!, title: event.title, body: "Reminder!", identifier: event.reminderID)
                    }
                }
                else {
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.scheduleNotifcation(at: event.date!, title: event.title, body: "Reminder!", identifier: event.reminderID)
                }
            }
            
            // Edit Calendar Entry.
            if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                
                editEventInCalendar(event: event!, toCalendar: calendarIdentifier as! String)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startDatePicker.date = event.date
        startDateLabel.text = dateFormatter.string(from: event.date)
        
        endDatePicker.date = event.endDate
        endDateLabel.text = dateFormatter.string(from: event.endDate)
        
        if type == "free" {
            startDatePicker.minimumDate = event.date
            endDatePicker.maximumDate = event.endDate
        }
        
        startDatePicker.isHidden = true
        endDatePicker.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        bottomLabel.textColor = UIColor.red
        bottomLabel.text = "Delete Event"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0 && indexPath.row == 1)
        {
            let height: CGFloat = startDatePicker.isHidden ? 0.0 : 217
            return height
        }
        
        if(indexPath.section == 0 && indexPath.row == 3)
        {
            let height: CGFloat = endDatePicker.isHidden ? 0.0 : 216
            return height
        }
        
        // Don't need delete button for free times page.
        if(indexPath.section == 1 && indexPath.row == 0 && type == "free")
        {
            return 0.0
        }
        
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let startDateIndexPath = IndexPath(row: 0, section: 0)
        let endDateIndexPath = IndexPath(row: 2, section: 0)

        
        //minimum study time = 15 mins
        let minTimeDifference : TimeInterval = 60
        
        if startDateIndexPath == indexPath {
            
            startDatePicker.isHidden = !startDatePicker.isHidden
            
            startDatePicker.maximumDate = endDatePicker.date.addingTimeInterval(-minTimeDifference)
            
            if !startDatePicker.isHidden {
                endDatePicker.isHidden = true
            }
        }
        else if endDateIndexPath == indexPath {

            endDatePicker.isHidden = !endDatePicker.isHidden
            
            endDatePicker.minimumDate = startDatePicker.date.addingTimeInterval(minTimeDifference)
            
            if !endDatePicker.isHidden {
                startDatePicker.isHidden = true
            }
        }
        
        // Bottom Button
        if indexPath.section == 1 && indexPath.row == 0 {
            if type == "alloc" { // Entering from allocated times page.
                
                // Remove any pending notifications for the event.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.reminderID])
                
                if let id = event.calEventID {
                    deleteEventFromCalendar(withID: id)
                }
                
                try! self.realm.write {
                    if let log = event.log {
                        self.realm.delete(log)
                    }
                    
                    self.realm.delete(event)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }

}
