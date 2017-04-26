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

class CourseAddViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let eventStore = EKEventStore();
    
    let colorPickerData = [["None", "Red", "Green", "Blue"]]
    /*
    func checkAllTextFields() {
        if ((unitTextField.text?.isEmpty)! || (courseTitleTextField.text?.isEmpty)! || (instructorTextField.text?.isEmpty)!) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }*/
    
    @IBAction func courseTitleChanged(_ sender: Any) {
        if ((courseTitleTextField.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 0, section: 0))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))!.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func courseChanged(_ sender: Any) {
        if ((identifierTextField.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func instructorChanged(_ sender: Any) {
        if ((instructorTextField.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func unitsChanged(_ sender: Any) {
        recommendedHours()
        if ((unitTextField.text?.isEmpty)! == false) && tableView.cellForRow(at: IndexPath(row: 3, section: 0))!.backgroundColor != UIColor.white {
            tableView.cellForRow(at: IndexPath(row: 3, section: 0))!.backgroundColor = UIColor.white
        }
    }
    
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
    
    @IBOutlet weak var colorLabel: UITextField!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    let realm = try! Realm()
    
    var color: UIColor!
    var editOrAdd: String = "" // "edit" or "add"
    
    var quarter: Quarter!
    
    var course: Course?
    var courses: Results<Course>!
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var courseTitleTextField: UITextField!
    @IBOutlet weak var recommendedTextField: UILabel!

    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func isDuplicate() -> Bool {
        let results = self.courses.filter("quarter.title = '\(quarter.title!)' AND identifier = '\(identifierTextField.text!)' AND title = '\(courseTitleTextField.text!)'")
        if results.count != 0 {
            let alert = UIAlertController(title: "Error", message: "Course identifier Already Exists", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    @IBAction func done(_ sender: Any) {
        if ((unitTextField.text?.isEmpty)! || (courseTitleTextField.text?.isEmpty)! || (identifierTextField.text?.isEmpty)! || (instructorTextField.text?.isEmpty)!) {
            let alert = UIAlertController(title: "Alert", message: "Missing Require Information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            if (self.unitTextField.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 3, section: 0))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
            
            if (self.courseTitleTextField.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 0, section: 0))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
            
            if (self.instructorTextField.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 2, section: 0))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
            
            if (self.identifierTextField.text?.isEmpty)! {
                tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
            }
            
        }
        else {
        
            if(editOrAdd=="add"){
                if isDuplicate() {
                    return
                }
                
                self.course = Course()
                course!.title = courseTitleTextField.text!
                course!.identifier = identifierTextField.text!
                course!.instructor = instructorTextField.text!
                course!.units = Float(unitTextField.text!)!
                course!.quarter = quarter
                course!.color = colorLabel.text!
                
                Helpers.DB_insert(obj: course!)
            }
            
            if(editOrAdd=="edit"){
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
        
        self.courses = self.realm.objects(Course.self)

        self.colorLabel.text = "None"
        
        if self.editOrAdd == "edit" {
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
        
        self.courses = self.realm.objects(Course.self)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if indexPath.section == 1 && indexPath.row == 0 {
            toggleShowColorPicker()
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if colorPicker.isHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        }
        else {
            return super.tableView(self.tableView, heightForRowAt: indexPath)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
