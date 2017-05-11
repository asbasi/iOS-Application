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
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var coursePicker: UIPickerView!
    
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var endDateLabel: UITextField!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBAction func setDate(_ sender: UIDatePicker) {
        
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func setEndDate(_ sender: UIDatePicker) {
        
        endDateLabel.text = dateFormatter.string(from: endDatePicker.date)
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
    
    /*
    private func checkAllTextFields() {
        
        if ((titleTextField.text?.isEmpty)! || (courseLabel.text?.isEmpty)! || (dateLabel.text?.isEmpty)! || (endDateLabel.text?.isEmpty)!) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }*/
    
    @IBAction func eventTitleChanged(_ sender: Any) {
        if ((titleTextField.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.backgroundColor = UIColor.white
        }
        
    }
    
    @IBAction func courseLabelChanged(_ sender: Any) {
        if ((courseLabel.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func dateLabelChanged(_ sender: Any) {
        if ((dateLabel.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 0, section: 1))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 0, section: 1))!.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func endDateLabelChanged(_ sender: Any) {
        if ((endDateLabel.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 2, section: 1))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 2, section: 1))!.backgroundColor = UIColor.white
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
            (self.dateLabel.text?.isEmpty)! || (self.endDateLabel.text?.isEmpty)!{
            
            let alert = UIAlertController(title: "Alert", message: "Missing Require Information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            if (self.titleTextField.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
            
            if (self.courseLabel.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
            
            if (self.dateLabel.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 0, section: 1))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
            
            if (self.endDateLabel.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 2, section: 1))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
        }
        
        else {
            //get the course
            let course = self.courses.filter("quarter.current = true AND identifier = '\(courses[coursePicker.selectedRow(inComponent: 0)].identifier!)'")[0]
            
            if(self.operation == "add" || self.operation == "manage") {
                let event = Event()
                
                event.title = titleTextField.text
                event.date = datePicker.date
                event.endDate = endDatePicker.date
                event.course = course
                event.type = segmentController.selectedSegmentIndex
                event.reminderID = UUID().uuidString
                event.duration = Date.getDifference(initial: event.date, final: event.endDate)
                
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
                    event!.endDate = dateFormatter.date(from: endDateLabel.text!)
                    event!.type = segmentController.selectedSegmentIndex
                    event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                    
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
            self.dateLabel.text = dateFormatter.string(from: self.event!.date)
            self.endDateLabel.text = dateFormatter.string(from: self.event!.endDate)
            self.courseLabel.text = self.event!.course.identifier
            self.segmentController.selectedSegmentIndex = self.event!.type
            
            //self.coursePicker.selectedRow(inComponent: self.coursePicker.index)
            if let date = self.event!.reminderDate {
                self.reminderSwitch.isOn = true
                self.reminderLabel.textColor = UIColor.blue
                self.reminderLabel.text = dateFormatter.string(from: date)
            }
        }
        
        // Ensure that the keyboard disappears when the user taps elsewhere.
        self.hideKeyboardWhenTapped()
        
        // Hide the save button.
        //self.checkAllTextFields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0 && indexPath.row == 3)
        {
            let height: CGFloat = coursePicker.isHidden ? 0.0 : 217
            return height
        }
        
        if(indexPath.section == 1 && indexPath.row == 1)
        {
            let height: CGFloat = datePicker.isHidden ? 0.0 : 216
            return height
        }
        
        if(indexPath.section == 1 && indexPath.row == 3)
        {
            let height: CGFloat = endDatePicker.isHidden ? 0.0 : 216
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
        
        let courseIndexPath = IndexPath(row: 2, section: 0)
        let dateIndexPath = IndexPath(row: 0, section: 1)
        let endDateIndexPath = IndexPath(row: 2, section: 1)
        let reminderIndexPath = IndexPath(row: 0, section: 2)
        
        //minimum study time = 15 mins
        let minTimeDifference : TimeInterval = 60
        
        if courseIndexPath == indexPath {
            coursePicker.isHidden = !coursePicker.isHidden
            
            if (courseLabel.text?.isEmpty)! {
                if courses.count != 0 {
                    self.coursePicker.selectRow(0, inComponent: 0, animated: false)
                    courseLabel.text = courses[0].identifier
                }
                
                if ((courseLabel.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor != UIColor.white {
                    tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor = UIColor.white
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
            //set  maximum time
            if (endDateLabel.text?.isEmpty)! == false {
                //datePicker.maximumDate = endDatePicker.date.addingTimeInterval(-minTimeDifference)
            }
            
            if (dateLabel.text?.isEmpty)! {
                datePicker.date = (Date())
                dateLabel.text = dateFormatter.string(from: datePicker.date)

                if ((dateLabel.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 0, section: 1))!.backgroundColor != UIColor.white {
                    tableView.cellForRow(at: IndexPath(row: 0, section: 1))!.backgroundColor = UIColor.white
                }
            }
            
            if !datePicker.isHidden {
                coursePicker.isHidden = true
                endDatePicker.isHidden = true
                reminderPicker.isHidden = true
            }
        }
        else if endDateIndexPath == indexPath {
            //force user to pick a start time first
            if (dateLabel.text?.isEmpty)! {
                let dateAlert = UIAlertController(title: "Alert", message: "Please Select Your Start Time.", preferredStyle: UIAlertControllerStyle.alert)
                dateAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(dateAlert, animated: true, completion: nil)
                
                tableView.cellForRow(at: dateIndexPath)!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
                
            else{
                //set minimum time
                //endDatePicker.minimumDate = datePicker.date.addingTimeInterval(minTimeDifference)
                
                endDatePicker.isHidden = !endDatePicker.isHidden
                
                
                if (endDateLabel.text?.isEmpty)! {
                    endDatePicker.date = datePicker.date.addingTimeInterval(900)
                    endDateLabel.text = dateFormatter.string(from: endDatePicker.date)
                    
                    if ((endDateLabel.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 2, section: 1))!.backgroundColor != UIColor.white {
                        tableView.cellForRow(at: IndexPath(row: 2, section: 1))!.backgroundColor = UIColor.white
                    }
                }
                
                if !endDatePicker.isHidden {
                    coursePicker.isHidden = true
                    datePicker.isHidden = true
                    reminderPicker.isHidden = true
                }
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
