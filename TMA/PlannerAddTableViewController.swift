//
//  PlannerAddTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 3/4/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import EventKit

class PlannerAddTableViewController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    let eventStore = EKEventStore();
    var goal: Goal!
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var courseLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func setDate(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    

    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderPicker: UIDatePicker!
    @IBAction func toggleReminderPicker(_ sender: Any) {
        reminderSwitch.isOn = !reminderSwitch.isOn
        
        if !reminderSwitch.isOn { // Turned Off
            reminderPicker.isHidden = true
            reminderLabel.textColor = UIColor.black
            reminderLabel.text = "Reminder"
        }
        else // Turned On
        {
            reminderPicker.isHidden = false
            reminderPicker.minimumDate = Date()
            reminderLabel.textColor = UIColor.blue
            setReminder(reminderPicker)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
    }

    @IBAction func setReminder(_ sender: UIDatePicker) {
        if !reminderPicker.isHidden {
            reminderLabel.text = dateFormatter.string(from: reminderPicker.date)
        }
    }
    
    
    private func checkAllTextFields() {
        if ((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)! || (dateLabel.text?.isEmpty)!) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }
    
    @IBAction func eventTitleChanged(_ sender: Any) {
        checkAllTextFields()
    }

    @IBAction func courseLabelChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    @IBAction func dateLabelChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    @IBAction func durationTitleChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    var operation: String = ""
    var event: Event?
    
    var dateFormatter = DateFormatter()
    
    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        //get the course
        
        
        
        if(self.operation == "add") {
            let event = Event()
            
            event.goal = self.goal
            event.course = self.goal.course
            event.type = self.goal.type
            
            event.title = titleTextField.text
            event.duration = Float(durationTextField.text!)!
            event.date = datePicker.date
            event.reminderID = UUID().uuidString

            if reminderSwitch.isOn {                
                // Schedule a notification.
                event.reminderDate = reminderPicker.date
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.scheduleNotifcation(at: event.reminderDate!, title: event.title, body: "Reminder!", identifier: event.reminderID)
            }
            else
            {
                event.reminderDate = nil
            }
            
            if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                
                event.calEventID = addEventToCalendar(event: event, toCalendar: calendarIdentifier as! String)
            }
            
            Helpers.DB_insert(obj: event)
            
        }
            
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {
                event!.title = titleTextField.text
                event!.duration = Float(durationTextField.text!)!
                event!.date = dateFormatter.date(from: dateLabel.text!)
                
                // Remove any existing notifications for this event.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event!.reminderID])
                
                
                if reminderSwitch.isOn {
                    // Schedule a notification.
                    event!.reminderDate = reminderPicker.date
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.scheduleNotifcation(at: event!.reminderDate!, title: event!.title, body: "Reminder!", identifier: event!.reminderID)
                }
                else
                {
                    event!.reminderDate = nil
                }
            }
            
            // Edit Calendar Entry.
            if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                
                editEventInCalendar(event: event!, toCalendar: calendarIdentifier as! String)
            }
        }
        
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    func addEventToCalendar(event: Event, toCalendar calendarIdentifier: String) -> String? {
        if let calendarForEvent = eventStore.calendar(withIdentifier: calendarIdentifier) {
            
            // Create the calendar event.
            let newEvent = EKEvent(eventStore: self.eventStore)
            
            newEvent.calendar = calendarForEvent
            newEvent.title = "\(event.title!) (\(event.course.name!))"
            newEvent.startDate = event.date
            
            var components = DateComponents()
            components.setValue(Int(event.duration), for: .hour)
            components.setValue(Int(round(60 * (event.duration - floor(event.duration)))), for: .minute)
            newEvent.endDate = Calendar.current.date(byAdding: components, to: event.date)!
            
            // Save the event in the calendar.
            do {
                try self.eventStore.save(newEvent, span: .thisEvent, commit: true)
                
                return newEvent.eventIdentifier
            }
            catch {
                let alert = UIAlertController(title: "Event could not save", message: (error as Error).localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(OKAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        return nil
    }
    
    func editEventInCalendar(event: Event, toCalendar calendarIdentifier: String) {
        if let calEvent = eventStore.event(withIdentifier: event.calEventID) {
            calEvent.title = "\(event.title!) (\(event.course.name!))"
            calEvent.startDate = event.date
            
            var components = DateComponents()
            components.setValue(Int(event.duration), for: .hour)
            components.setValue(Int(round(60 * (event.duration - floor(event.duration)))), for: .minute)
            calEvent.endDate = Calendar.current.date(byAdding: components, to: event.date)!
            
            do {
                try self.eventStore.save(calEvent, span: .thisEvent, commit: true)
            }
            catch {
                let alert = UIAlertController(title: "Event could not edited", message: (error as Error).localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(OKAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            // Event with identifier doesn't exist so make it.
            try! self.realm.write {
               event.calEventID = addEventToCalendar(event: event, toCalendar: calendarIdentifier)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        self.courseLabel.isEnabled = false
        self.dateLabel.isEnabled = false
        self.segmentController.isEnabled = false
        
        self.tableView.tableFooterView = UIView()
        
        // Text field setup
        self.titleTextField.delegate = self
        self.durationTextField.delegate = self
        
        // Date picker setup
        self.datePicker.isHidden = true

        // Reminder setup
        self.reminderLabel.text = "Reminder"
        self.reminderSwitch.isOn = false
        self.reminderPicker.isHidden = true
        
        
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Event"
            
            //type and course are preset
            self.segmentController.selectedSegmentIndex = self.goal.type
            self.courseLabel.text = self.goal.course.identifier

        }
        else if (self.operation == "edit" || self.operation == "show") {
            self.goal = self.event!.goal
            self.segmentController.selectedSegmentIndex = self.goal.type
            self.courseLabel.text = self.goal.course.identifier
            
            self.pageTitleTextField.title = self.event!.title
            self.titleTextField.text = self.event!.title
            self.durationTextField.text = "\(self.event!.duration)"
            self.dateLabel.text = dateFormatter.string(from: self.event!.date)
            
            
            if let date = self.event!.reminderDate {
                self.reminderSwitch.isOn = true
                self.reminderLabel.textColor = UIColor.blue
                self.reminderLabel.text = dateFormatter.string(from: date)
            }
        }
        
        // Ensure that the keyboard disappears when the user taps elsewhere.
        self.hideKeyboardWhenTapped()
        
        // Hide the save button.
        self.checkAllTextFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 1 && indexPath.row == 1)
        {
            let height: CGFloat = datePicker.isHidden ? 0.0 : 216
            return height
        }
        
        if(indexPath.section == 2 && indexPath.row == 1)
        {
            let height: CGFloat = reminderPicker.isHidden ? 0.0 : 216
            return height
        }
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let dateIndexPath = IndexPath(row: 0, section: 1)
        let reminderIndexPath = IndexPath(row: 0, section: 2)
        
        
        if dateIndexPath == indexPath {
            
            datePicker.isHidden = !datePicker.isHidden
            
            if (dateLabel.text?.isEmpty)! {
                dateLabel.text = dateFormatter.string(from: Date())
            }
            
            if !datePicker.isHidden {
                reminderPicker.isHidden = true
            }
        }
        else if reminderIndexPath == indexPath {
            if !reminderSwitch.isOn {
                toggleReminderPicker(self)
            }
            else {
                reminderPicker.isHidden = !reminderPicker.isHidden
            }
            
            if !reminderPicker.isHidden {
                datePicker.isHidden = true
            }
        }
            
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
