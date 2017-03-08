//
//  CourseAddViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class CourseAddViewController: UITableViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    let quarterPickerData = [
        ["Fall 2016","Winter 2017","Spring 2017"]
    ]
    let colorPickerData = [
        ["Red", "Green", "Blue"]  //for now
    ]
    
    func checkAllTextFields() {
        if unitTextField.text == "" || nameTextField.text == "" || instructorTextField.text == "" {
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
    
    
    var dpShowQuarterVisible = false
    var dpShowColorVisible = false
    
    private func toggleShowQuarterPicker () {
        dpShowQuarterVisible = !dpShowQuarterVisible
        if dpShowQuarterVisible && dpShowColorVisible {
            dpShowColorVisible = false
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    private func toggleShowColorPicker () {
        dpShowColorVisible = !dpShowColorVisible
        if dpShowQuarterVisible && dpShowColorVisible {
            dpShowQuarterVisible = false
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var quarterPicker: UIPickerView!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    let realm = try! Realm()
    
    var course: Course?
    var color: UIColor!
    var editOrAdd: String = "" // "edit" or "add"
    var courses: Results<Course>!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    
    @IBOutlet weak var quarterLabel: UILabel!
    
    
    @IBOutlet weak var recommendedTextField: UITextField!
    
    @IBAction func recommendedText(_ sender: Any) {
        if(!(unitTextField.text?.isEmpty)!)
        {
            let recommendedHoursPerUnit = 3
            
            //            recommendedTextField!.text = "\(Int(unitTextField.text!)! * recommendedHoursPerUnit) hours/week recommended."
        }
    }
    
    
    @IBAction func done(_ sender: Any) {
        if(editOrAdd=="add") {
            let results = self.courses.filter("name = '\(nameTextField.text!)'")
            if results.count != 0 {
                let alert = UIAlertController(title: "Error", message: "Course Name Already Exists", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if(editOrAdd=="add"){
            self.course = Course()
            course!.name = nameTextField.text!
            
            course!.instructor = instructorTextField.text!
            course!.units = Int(unitTextField.text!)!
            course!.quarter = quarterLabel.text!
            course!.courseColor = colorLabel.text!
            Helpers.DB_insert(obj: course!)
            
        }
        if(editOrAdd=="edit"){
            try! self.realm.write {
                course!.name = nameTextField.text!
                
                course!.instructor = instructorTextField.text!
                course!.units = Int(unitTextField.text!)!
                course!.quarter = quarterLabel.text!
                course!.courseColor = colorLabel.text!
            }
        }

        let _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.quarterPicker.showsSelectionIndicator = true
        
        self.quarterPicker.dataSource = self
        self.quarterPicker.delegate = self
        
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        
        self.tableView.tableFooterView = UIView()
        
        self.courses = self.realm.objects(Course.self)
        
        if self.editOrAdd == "edit" {
            self.nameTextField.text = self.course!.name
            self.instructorTextField.text = self.course!.instructor
            self.unitTextField.text = "\(self.course!.units)"
            
            let quarterRow = quarterPickerData[0].index(of: self.course!.quarter)
            self.quarterPicker.selectRow(quarterRow!, inComponent: 0, animated: true)
            self.quarterLabel.text = self.course!.quarter
            
            let colorRow = colorPickerData[0].index(of: self.course!.courseColor)
            self.colorPicker.selectRow(colorRow!, inComponent: 0, animated: true)
            self.colorLabel.text = self.course!.courseColor
            
            recommendedText(self)
        }
        
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
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
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
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
        if indexPath.row == 4 {
            toggleShowQuarterPicker()
        }
        else if indexPath.row == 6 {
            toggleShowColorPicker()
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !dpShowQuarterVisible && indexPath.row == 5 {
            return 0
        }
        else if !dpShowColorVisible && indexPath.row == 7 {
            return 0
        }
        else {
            return super.tableView(self.tableView, heightForRowAt: indexPath)
        }
    }
    
}
