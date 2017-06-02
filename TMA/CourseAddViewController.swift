//
//  CourseAddViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift
import EventKit
/// Class containing all code related to the Course Add/Edit page
class CourseAddViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let eventStore = EKEventStore()
    
    @IBOutlet weak var colorLabel: UITextField!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    let realm = try! Realm()
    
    var color: UIColor!
    var editOrAdd: String = "" // "edit" or "add"
    
    var quarter: Quarter!
    var course: Course?
    
    let colorPickerData = [Array(colorMappings.keys)]
    
    let titlePath = IndexPath(row: 0, section: 0)
    let coursePath = IndexPath(row: 1, section: 0)
    let insPath = IndexPath(row: 2, section: 0)
    let unitPath = IndexPath(row: 3, section: 0)
    let colorPath = IndexPath(row: 0, section: 1)
    let colorPickerPath = IndexPath(row: 1, section: 1)
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var courseTitleTextField: UITextField!
    @IBOutlet weak var recommendedTextField: UILabel!
    
    /// Check if the course title has change
    @IBAction func courseTitleChanged(_ sender: Any) {
        if ((courseTitleTextField.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: titlePath)
        }
    }
    
    /// Check if the course identifier has changed
    @IBAction func courseChanged(_ sender: Any) {
        if ((identifierTextField.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: coursePath)
        }
    }
    
    /// Check if the istructor name has changed
    @IBAction func instructorChanged(_ sender: Any) {
        if ((instructorTextField.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: insPath)
        }
    }
    
    /// Check if the course unit has changed
    @IBAction func unitsChanged(_ sender: Any) {
        recommendedHours()
        if ((unitTextField.text?.isEmpty)! == false) {
            changeTextFieldToWhite(indexPath: unitPath)
        }
    }
    
    /// Calculates recommended study hours based on the number of units
    private func recommendedHours() {
        if unitTextField.text != "" {
            if Float(unitTextField.text!) != nil {
                recommendedTextField.text = "\(Float(unitTextField.text!)! * 3) hours/week recommended."
            }
        }
        else {
            recommendedTextField.text = ""
        }
    }
    
    private func toggleShowColorPicker () {
        colorPicker.isHidden = !colorPicker.isHidden

        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
        
        // Get rid of any saved schedules for this course.
        if editOrAdd == "add" {
            let schedulesToDelete = self.realm.objects(Schedule.self).filter("course.identifier = '\(course!.identifier!)'")
            
            for schedule in schedulesToDelete {
                schedule.delete(from: realm)
            }
        }
    }
    
    /// Check for duplicate by comparing the new course enrty with the data in the database
    private func isDuplicate() -> Bool {
        let results = self.realm.objects(Course.self).filter("quarter.title = '\(quarter.title!)' AND identifier = '\(identifierTextField.text!)' AND title = '\(courseTitleTextField.text!)'")
        if results.count != 0 {
            let alert = UIAlertController(title: "Error", message: "Course identifier Already Exists", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    /// Save the new course after checks the correctness of its entries
    @IBAction func done(_ sender: Any) {
    
        if ((unitTextField.text?.isEmpty)! || (courseTitleTextField.text?.isEmpty)! || (identifierTextField.text?.isEmpty)! || (instructorTextField.text?.isEmpty)!) {
            let alert = UIAlertController(title: "Alert", message: "Missing Required Information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            if (self.unitTextField.text?.isEmpty)! {
                changeTextFieldToRed(indexPath: unitPath)
            }
            
            if (self.courseTitleTextField.text?.isEmpty)! {
                changeTextFieldToRed(indexPath: titlePath)
            }
            
            if (self.instructorTextField.text?.isEmpty)! {
                changeTextFieldToRed(indexPath: insPath)
            }
            
            if (self.identifierTextField.text?.isEmpty)! {
                changeTextFieldToRed(indexPath: coursePath)
            }
            
        }
        else {
        
            if(editOrAdd=="add"){
                if isDuplicate() {
                    return
                }
                
                // Note: At this point the identifier for the course is a massive uuid string that was assigned temporarily.
                let schedules = self.realm.objects(Schedule.self).filter("course.identifier = '\(course!.identifier!)'")
                
                for schedule in schedules {
                    schedule.export(to: realm)
                }
                
                course!.title = courseTitleTextField.text!
                course!.identifier = identifierTextField.text!
                course!.instructor = instructorTextField.text!
                course!.units = Float(unitTextField.text!)!
                course!.quarter = quarter
                course!.color = colorLabel.text!
                
                Helpers.DB_insert(obj: course!)
            }
            else if(editOrAdd=="edit"){
                try! self.realm.write {
                    
                    if course!.title != courseTitleTextField.text! {
                        if isDuplicate() {
                            return
                        }
                        else {
                            course!.title = courseTitleTextField.text!
                        }
                    }

                    course!.identifier = identifierTextField.text!
                    course!.instructor = instructorTextField.text!
                    course!.units = Float(unitTextField.text!)!
                    course!.quarter = quarter
                    course!.color = colorLabel.text!
                }
            }

            self.dismissKeyboard()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.identifierTextField.delegate = self
        self.instructorTextField.delegate = self
        self.unitTextField.delegate = self
        self.courseTitleTextField.delegate = self
        
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        self.colorPicker.isHidden = true
        
        self.tableView.tableFooterView = UIView()

        self.colorLabel.text = colorPickerData[0].first
        
        if self.editOrAdd == "add" {
            self.course = Course()
            self.course!.identifier = UUID().uuidString // Assign it a temporary identifier.
            self.course!.quarter = quarter // Assign it to the current quarter.
        }
        else if self.editOrAdd == "edit" {
            self.navigationItem.title = self.course!.title
            
            self.courseTitleTextField.text = self.course!.title
            self.identifierTextField.text = self.course!.identifier
            self.instructorTextField.text = self.course!.instructor
            self.unitTextField.text = "\(self.course!.units)"
            
            let colorRow = colorPickerData[0].index(of: self.course!.color)
            self.colorPicker.selectRow(colorRow!, inComponent: 0, animated: true)
            self.colorLabel.text = self.course!.color
            
            recommendedHours()
        }
        
        self.hideKeyboardWhenTapped()
        
        //checkAllTextFields()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    //MARK: - Picker View Data Sources and Delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorPickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colorPickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        self.colorLabel.text = colorPickerData[component][row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == colorPath {
            toggleShowColorPicker()
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if colorPicker.isHidden && indexPath == colorPickerPath {
            return 0
        }
        else {
            return super.tableView(self.tableView, heightForRowAt: indexPath)
        }
    }
    
    /******************************* Text Field Functions *******************************/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "courseSchedule" {
            
            let courseScheduleViewController = segue.destination as! ScheduleMainTableViewController
            courseScheduleViewController.course = self.course
            courseScheduleViewController.mode = self.editOrAdd
        }

        
    }
}
