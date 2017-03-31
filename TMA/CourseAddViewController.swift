//
//  CourseAddViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class CourseAddViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let colorPickerData = [["None", "Red", "Green", "Blue"]]
    
    func checkAllTextFields() {
        if unitTextField.text == "" || courseTitleTextField.text == "" || instructorTextField.text == "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }
    
    @IBAction func courseChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    @IBAction func instructorChanged(_ sender: Any) {
        checkAllTextFields()
    }
    @IBAction func unitsChanged(_ sender: Any) {
        checkAllTextFields()
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
    

    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func isDuplicate() -> Bool {
        let results = self.courses.filter("quarter.title = '\(quarter.title!)' AND identifier = '\(identifierTextField.text!)'")
        if results.count != 0 {
            let alert = UIAlertController(title: "Error", message: "Course identifier Already Exists", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    @IBAction func done(_ sender: Any) {
    
        print ("\(quarter.title)")
        if(editOrAdd=="add"){
            if isDuplicate() {
                return
            }
            
            self.course = Course()
            course!.name = courseTitleTextField.text!
            course!.identifier = identifierTextField.text!
            course!.instructor = instructorTextField.text!
            course!.units = Float(unitTextField.text!)!
            course!.quarter = quarter
            course!.color = colorLabel.text!
            Helpers.DB_insert(obj: course!)
            
        }
        if(editOrAdd=="edit"){
            try! self.realm.write {
                
                if course!.name != courseTitleTextField.text! {
                    if isDuplicate() {
                        return
                    }
                    else {
                        course!.name = courseTitleTextField.text!
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
            self.courseTitleTextField.text = self.course!.name
            self.identifierTextField.text = self.course!.identifier
            self.instructorTextField.text = self.course!.instructor
            self.unitTextField.text = "\(self.course!.units)"
            
            let colorRow = colorPickerData[0].index(of: self.course!.color)
            self.colorPicker.selectRow(colorRow!, inComponent: 0, animated: true)
            self.colorLabel.text = self.course!.color
        }
        
        self.hideKeyboardWhenTapped()
        
        checkAllTextFields()
        
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
