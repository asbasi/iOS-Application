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

class PlannerAddTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var coursePicker: UIPickerView!
    
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
    
    
    func checkAllTextFields() {
        if ((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)! ||
            (courseLabel.text?.isEmpty)! || (dateLabel.text?.isEmpty)!) {
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
    var courses: Results<Course>!
    var dateFormatter = DateFormatter()
    
    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        //get the course
        let course = self.courses.filter("identifier = '\(courses[coursePicker.selectedRow(inComponent: 0)].identifier!)'")[0]
        
        if(self.operation == "add") {
            let event = Event()
            
            event.title = titleTextField.text
            event.duration = Float(durationTextField.text!)!
            event.date = datePicker.date
            event.course = course
            event.type = segmentController.selectedSegmentIndex
            event.id = UUID().uuidString

            if reminderSwitch.isOn {                
                // Schedule a notification.
                event.reminderDate = reminderPicker.date
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.scheduleNotifcation(at: event.reminderDate!, title: event.title, body: "Reminder!", identifier: event.id)
            }
            else
            {
                event.reminderDate = nil
            }
            
            Helpers.DB_insert(obj: event)
            
        }
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {
                event!.title = titleTextField.text
                event!.duration = Float(durationTextField.text!)!
                event!.course = course
                event!.date = dateFormatter.date(from: dateLabel.text!)
                event!.type = segmentController.selectedSegmentIndex
                
                // Remove any existing notifications for this event.
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event!.id])
                
                if reminderSwitch.isOn {
                    // Schedule a notification.
                    event!.reminderDate = reminderPicker.date
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.scheduleNotifcation(at: event!.reminderDate!, title: event!.title, body: "Reminder!", identifier: event!.id)
                }
                else
                {
                    event!.reminderDate = nil
                }
            }
        }
        
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        self.courseLabel.isEnabled = false
        self.dateLabel.isEnabled = false
        
        self.courses = self.realm.objects(Course.self)
        
        self.tableView.tableFooterView = UIView()
        
        // Text field setup
        self.titleTextField.delegate = self
        self.durationTextField.delegate = self
        
        // Course picker setup
        self.coursePicker.showsSelectionIndicator = true
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        self.coursePicker.isHidden = true
        
        // Date picker setup
        self.datePicker.isHidden = true

        // Reminder setup
        self.reminderLabel.text = "Reminder"
        self.reminderSwitch.isOn = false
        self.reminderPicker.isHidden = true
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Event"
        }
        else if (self.operation == "edit" || self.operation == "show") {
            self.pageTitleTextField.title = self.event!.title
            self.titleTextField.text = self.event!.title
            self.durationTextField.text = "\(self.event!.duration)"
            self.dateLabel.text = dateFormatter.string(from: self.event!.date)
            self.courseLabel.text = self.event!.course.identifier
            self.segmentController.selectedSegmentIndex = self.event!.type
            
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

    /*
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return super.tableView(tableView, viewForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView,  heightForFooterInSection section: Int) -> CGFloat {

        return super.tableView(tableView, heightForFooterInSection: section)
    }
    */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else if section == 1 {
            return 3
        }
        else if section == 2 {
            return 2
        }
        
        return 0
    }
    
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
        let reminderIndexPath = IndexPath(row: 0, section: 2)
        
        if courseIndexPath == indexPath {
            coursePicker.isHidden = !coursePicker.isHidden
            
            if (courseLabel.text?.isEmpty)! {
                if courses.count != 0 {
                    self.coursePicker.selectRow(0, inComponent: 0, animated: false)
                    courseLabel.text = courses[0].identifier
                }
            }
            
            if !coursePicker.isHidden {
                datePicker.isHidden = true
                reminderPicker.isHidden = true
            }
        }
        else if dateIndexPath == indexPath {
            
            datePicker.isHidden = !datePicker.isHidden
            
            if (dateLabel.text?.isEmpty)! {
                dateLabel.text = dateFormatter.string(from: Date())
            }
            
            if !datePicker.isHidden {
                coursePicker.isHidden = true
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
