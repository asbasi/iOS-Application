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

class PlannerAddTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    let realm = try! Realm()
    let eventStore = EKEventStore()
    
    let typePath = IndexPath(row: 1, section: 0)
    let titlePath = IndexPath(row: 2, section: 0)
    let coursePath = IndexPath(row: 3, section: 0)
    let coursePickerPath = IndexPath(row: 4, section: 0)
    let startPath = IndexPath(row: 0, section: 1)
    let startPickerPath = IndexPath(row: 1, section: 1)
    let endPath = IndexPath(row: 2, section: 1)
    let endPickerPath = IndexPath(row: 3, section: 1)
    let reminderPickerPath = IndexPath(row: 1, section: 2)
    
    @IBOutlet weak var deadlineSwitch: UISwitch!
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var coursePicker: UIPickerView!
    
    @IBOutlet weak var startDateText: UILabel!
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var endDateLabel: UITextField!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderPicker: UIDatePicker!
    
    @IBAction func toggledDuration(_ sender: Any) {
        
        // Get rid of the endDatePicker.
        //endDateLabel.text = nil
        endDatePicker.isHidden = true
        
        if deadlineSwitch.isOn {
            startDateText.text = "Deadline"
        }
        else {
            startDateText.text = "Start Time"
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
    }
    
    @IBAction func setDate(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func setEndDate(_ sender: UIDatePicker) {
        endDateLabel.text = dateFormatter.string(from: endDatePicker.date)
    }
    
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
    
    //change textfiled to white when it's not empty
    @IBAction func eventTitleChanged(_ sender: Any) {
        if ((titleTextField.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: titlePath)
        }
        
    }
    
    @IBAction func courseLabelChanged(_ sender: Any) {
        if ((courseLabel.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: coursePath)
        }
    }
    
    @IBAction func dateLabelChanged(_ sender: Any) {
        if ((dateLabel.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: startPath)
        }
    }
    
    @IBAction func endDateLabelChanged(_ sender: Any) {
        if ((endDateLabel.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: endPath)
        }
    }
    
    var operation: String = ""
    var event: Event?
    var courses: Results<Course>!
    var dateFormatter = DateFormatter()
    
    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        if (self.titleTextField.text?.isEmpty)! || (self.courseLabel.text?.isEmpty)! ||
            (self.dateLabel.text?.isEmpty)! || ((self.endDateLabel.text?.isEmpty)! && !deadlineSwitch.isOn) {
            
            let alert = UIAlertController(title: "Alert", message: "Missing Required Information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            if (self.titleTextField.text?.isEmpty)! {
                changeTextFieldToRed(indexPath: titlePath)
            }
            
            if (self.courseLabel.text?.isEmpty)! {
                changeTextFieldToRed(indexPath: coursePath)
            }
            
            if (self.dateLabel.text?.isEmpty)! {
                changeTextFieldToRed(indexPath: startPath)
            }
            
            if (self.endDateLabel.text?.isEmpty)! && !deadlineSwitch.isOn {
                changeTextFieldToRed(indexPath: endPath)
            }
        }
        else if(!deadlineSwitch.isOn && dateFormatter.date(from: dateLabel.text!)! >= dateFormatter.date(from: endDateLabel.text!)!) {
            let alert = UIAlertController(title: "Alert", message: "Invalid dates selected. Ensure that the start date is before the end date.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            changeTextFieldToRed(indexPath: startPath)
            
            changeTextFieldToRed(indexPath: endPath)
        }
        else {
            //get the course
            let course = self.courses.filter(NSPredicate(format: "quarter.current = true AND identifier == %@", courseLabel.text!))[0]
            
            if(self.operation == "add" || self.operation == "manage") {
                let event = Event()
                
                event.title = titleTextField.text
                event.date = dateFormatter.date(from: dateLabel.text!)
                event.course = course
                
                if deadlineSwitch.isOn {
                    event.endDate = event.date
                    event.type = DEADLINE_EVENT
                    event.duration = 0.0
                }
                else {
                    event.endDate = dateFormatter.date(from: endDateLabel.text!)
                    event.type = segmentController.selectedSegmentIndex
                    event.duration = Date.getDifference(initial: event.date, final: event.endDate)
                }
                
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
                    event!.course = course
                    event!.date = dateFormatter.date(from: dateLabel.text!)
                    
                    if(deadlineSwitch.isOn) {
                        event!.endDate = event!.date
                        event!.type = DEADLINE_EVENT
                        event!.duration = 0.0
                    }
                    else {
                        event!.endDate = dateFormatter.date(from: endDateLabel.text!)
                        event!.type = segmentController.selectedSegmentIndex
                        event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                    }
                    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.courses = self.realm.objects(Course.self).filter("quarter.current = true")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        self.courseLabel.isEnabled = false
        self.dateLabel.isEnabled = false
        self.endDateLabel.isEnabled = false
        
        self.courses = self.realm.objects(Course.self).filter("quarter.current = true")
        
        self.tableView.tableFooterView = UIView()
        
        // Text field setup
        self.titleTextField.delegate = self
        
        // Course picker setup
        self.coursePicker.showsSelectionIndicator = true
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        self.coursePicker.isHidden = true
        
        // Date picker setup
        self.datePicker.isHidden = true
        self.endDatePicker.isHidden = true
        
        // Reminder setup
        self.reminderLabel.text = "Reminder"
        self.reminderSwitch.isOn = false
        self.reminderPicker.isHidden = true
        
        // Deadline switch.
        self.deadlineSwitch.isOn = false
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Event"
        }
        else if(self.operation == "manage") {
            self.pageTitleTextField.title = "Manage Free Time"
            self.datePicker.date = self.event!.date
            self.dateLabel.text = dateFormatter.string(from: self.event!.date)
            
            self.endDatePicker.date = self.event!.endDate
            self.endDateLabel.text = dateFormatter.string(from: self.event!.endDate)
        }
        else if (self.operation == "edit" || self.operation == "show") {
            self.pageTitleTextField.title = self.event!.title
            self.titleTextField.text = self.event!.title
            self.courseLabel.text = self.event!.course.identifier
            self.dateLabel.text = dateFormatter.string(from: self.event!.date)
            
            if(self.event!.type == DEADLINE_EVENT) {
                self.deadlineSwitch.isOn = true
            }
            else {
                self.endDateLabel.text = dateFormatter.string(from: self.event!.endDate)
                self.segmentController.selectedSegmentIndex = self.event!.type
            }
            
            if let date = self.event!.reminderDate {
                self.reminderSwitch.isOn = true
                self.reminderLabel.textColor = UIColor.blue
                self.reminderLabel.text = dateFormatter.string(from: date)
            }
        }
        
        // Ensure that the keyboard disappears when the user taps elsewhere.
        self.hideKeyboardWhenTapped()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (deadlineSwitch.isOn && (indexPath == typePath || indexPath == endPath))
        {
            return 0.0
        }
        else if indexPath == coursePickerPath
        {
            let height: CGFloat = coursePicker.isHidden ? 0.0 : 217
            return height
        }
        else if indexPath == startPickerPath
        {
            let height: CGFloat = datePicker.isHidden ? 0.0 : 216
            return height
        }
        else if indexPath == endPickerPath
        {
            let height: CGFloat = endDatePicker.isHidden ? 0.0 : 216
            return height
        }
        else if indexPath == reminderPickerPath
        {
            let height: CGFloat = reminderPicker.isHidden ? 0.0 : 216
            return height
        }
        
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let courseIndexPath = IndexPath(row: 3, section: 0)
        let dateIndexPath = IndexPath(row: 0, section: 1)
        let endDateIndexPath = IndexPath(row: 2, section: 1)
        let reminderIndexPath = IndexPath(row: 0, section: 2)
        
        if courseIndexPath == indexPath {
            coursePicker.isHidden = !coursePicker.isHidden
            
            if (courseLabel.text?.isEmpty)! {
                if courses.count != 0 {
                    self.coursePicker.selectRow(0, inComponent: 0, animated: false)
                    courseLabel.text = courses[0].identifier
                }
                
                if ((courseLabel.text?.isEmpty)! == false) {
                    changeTextFieldToWhite(indexPath: courseIndexPath)
                }
            }
            
            if !coursePicker.isHidden {
                datePicker.isHidden = true
                endDatePicker.isHidden = true
                reminderPicker.isHidden = true
            }
        }
        else if dateIndexPath == indexPath {
            
            datePicker.isHidden = !datePicker.isHidden
            if tableView.cellForRow(at: dateIndexPath)!.backgroundColor != UIColor.white {
                tableView.cellForRow(at: dateIndexPath)!.backgroundColor = UIColor.white
            }
            
            if (dateLabel.text?.isEmpty)! {
                datePicker.date = Date()
                dateLabel.text = dateFormatter.string(from: datePicker.date)

                if ((dateLabel.text?.isEmpty)! == false) {
                    changeTextFieldToWhite(indexPath: dateIndexPath)
                }
            }
            
            if !datePicker.isHidden {
                coursePicker.isHidden = true
                endDatePicker.isHidden = true
                reminderPicker.isHidden = true
            }
        }
        else if endDateIndexPath == indexPath && !deadlineSwitch.isOn {
                
            endDatePicker.isHidden = !endDatePicker.isHidden
            
            
            if (endDateLabel.text?.isEmpty)! {
                endDatePicker.date = datePicker.date.addingTimeInterval(900)
                endDateLabel.text = dateFormatter.string(from: endDatePicker.date)
                
                if ((endDateLabel.text?.isEmpty)! == false) {
                    changeTextFieldToWhite(indexPath: endDateIndexPath)
                }
                
            }
            
            if !endDatePicker.isHidden {
                coursePicker.isHidden = true
                datePicker.isHidden = true
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
                coursePicker.isHidden = true
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component:Int ) -> String? {
        return self.courses[row].identifier
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        courseLabel.text = courses[row].identifier
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
