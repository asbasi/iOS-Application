//
//  CourseAddViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class CourseAddViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let quarterPickerData = [["Fall 2016","Winter 2017","Spring 2017"]]
    let colorPickerData = [["None", "Red", "Green", "Blue"]]
    
    func checkAllTextFields() {
        if unitTextField.text == "" || courseTitleTextField.text == "" || instructorTextField.text == "" || identifierTextField.text == "" {
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
    
    private func toggleShowQuarterPicker () {
        quarterPicker.isHidden = !quarterPicker.isHidden
        if !quarterPicker.isHidden && !colorPicker.isHidden {
            colorPicker.isHidden = true
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    private func toggleShowColorPicker () {
        colorPicker.isHidden = !colorPicker.isHidden
        if !quarterPicker.isHidden && !colorPicker.isHidden {
            quarterPicker.isHidden = true
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    @IBOutlet weak var quarterPicker: UIPickerView!
    @IBOutlet weak var quarterLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    let realm = try! Realm()
    
    var course: Course?
    var color: UIColor!
    var editOrAdd: String = "" // "edit" or "add"
    var courses: Results<Course>!
    
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var courseTitleTextField: UITextField!
    

    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        if(editOrAdd=="add") {
            // Will eventually need to change this to allow the same course in different quarters.
            let results = self.courses.filter("identifier = '\(identifierTextField.text!)'")
            if results.count != 0 {
                let alert = UIAlertController(title: "Error", message: "Course Name Already Exists", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if(editOrAdd=="add"){
            self.course = Course()
            course!.name = courseTitleTextField.text!
            course!.identifier = identifierTextField.text!
            course!.instructor = instructorTextField.text!
            course!.units = Float(unitTextField.text!)!
            course!.quarter = quarterLabel.text!
            course!.color = colorLabel.text!
            Helpers.DB_insert(obj: course!)
            
        }
        if(editOrAdd=="edit"){
            try! self.realm.write {
                course!.name = courseTitleTextField.text!
                course!.identifier = identifierTextField.text!
                course!.instructor = instructorTextField.text!
                course!.units = Float(unitTextField.text!)!
                course!.quarter = quarterLabel.text!
                course!.color = colorLabel.text!
            }
        }

        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.quarterPicker.showsSelectionIndicator = true
        self.quarterPicker.dataSource = self
        self.quarterPicker.delegate = self
        self.quarterPicker.isHidden = true
        
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        self.colorPicker.isHidden = true
        
        self.tableView.tableFooterView = UIView()
        
        self.courses = self.realm.objects(Course.self)
        
        if self.editOrAdd == "edit" {
            self.courseTitleTextField.text = self.course!.name
            self.identifierTextField.text = self.course!.identifier
            self.instructorTextField.text = self.course!.instructor
            self.unitTextField.text = "\(self.course!.units)"
            
            let quarterRow = quarterPickerData[0].index(of: self.course!.quarter)
            self.quarterPicker.selectRow(quarterRow!, inComponent: 0, animated: true)
            self.quarterLabel.text = self.course!.quarter
            
            let colorRow = colorPickerData[0].index(of: self.course!.color)
            self.colorPicker.selectRow(colorRow!, inComponent: 0, animated: true)
            self.colorLabel.text = self.course!.color
        }
        
        self.hideKeyboardWhenTapped()
        
        checkAllTextFields()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Picker View Data Sources and Delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == quarterPicker{
            return quarterPickerData.count
        }
        else if pickerView == colorPicker{
            return colorPickerData.count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == quarterPicker{
            return quarterPickerData[component].count
        }else if pickerView == colorPicker{
            return colorPickerData[component].count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == quarterPicker{
            return quarterPickerData[component][row]
        }
        else if pickerView == colorPicker{
            return colorPickerData[component][row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == quarterPicker{
            self.quarterLabel.text = quarterPickerData[component][row]
        }else if pickerView == colorPicker{
            self.colorLabel.text = colorPickerData[component][row]
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            toggleShowQuarterPicker()
        }
        else if indexPath.section == 1 && indexPath.row == 2 {
            toggleShowColorPicker()
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if quarterPicker.isHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        }
        else if colorPicker.isHidden && indexPath.section == 1 && indexPath.row == 3 {
            return 0
        }
        else {
            return super.tableView(self.tableView, heightForRowAt: indexPath)
        }
    }
}
