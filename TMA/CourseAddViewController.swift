//
//  CourseAddViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class CourseAddViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    let pickerData = [
        ["Fall 2016","Winter 2017","Spring 2017"]
    ]
    let pickerColor = [
        ["Red", "Green", "Blue"]  //for now
    ]
    var quarterPicker = UIPickerView()
    var colorPicker = UIPickerView()
    
    let realm = try! Realm()
    
    var course: Course?
    var color: UIColor!
    var editOrAdd: String = "" // "edit" or "add"
    var courses: Results<Course>!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var recommendedTextField: UITextField!
    @IBOutlet weak var quarterTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!

    
    @IBAction func recommendedText(_ sender: Any) {
        if(!(unitTextField.text?.isEmpty)!)
        {
            let recommendedHoursPerUnit = 3
            
            recommendedTextField!.text = "\(Int(unitTextField.text!)! * recommendedHoursPerUnit) hours/week recommended."
        }
    }
    
    @IBAction func done(_ sender: Any) {
        
        if(editOrAdd=="add"){
            let results = self.courses.filter("name = '\(nameTextField.text!)'")
            if results.count != 0 {
                return
            }
        }
        
        if((nameTextField.text?.isEmpty)! || (instructorTextField.text?.isEmpty)! || (unitTextField.text?.isEmpty)!) {
            return
        }

        
        if(editOrAdd=="add"){
            self.course = Course()
            course!.name = nameTextField.text!
            
            course!.instructor = instructorTextField.text!
            course!.units = Int(unitTextField.text!)!
            course!.quarter = quarterTextField.text!
            course!.courseColor = colorTextField.text!
            Helpers.DB_insert(obj: course!)
            
        }
        if(editOrAdd=="edit"){
            try! self.realm.write {
                course!.name = nameTextField.text!
                
                course!.instructor = instructorTextField.text!
                course!.units = Int(unitTextField.text!)!
                course!.quarter = quarterTextField.text!
                course!.courseColor = colorTextField.text!
            }
        }
        
        
        
        
        let _ = self.navigationController?.popViewController(animated: true)

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.quarterPicker.showsSelectionIndicator = true
        self.quarterPicker.dataSource = self
        self.quarterPicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(quarterDonePressed))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.quarterTextField.inputView = quarterPicker
        self.quarterTextField.inputAccessoryView = toolBar
        
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        self.colorTextField.inputView = colorPicker
        
        self.quarterPicker.dataSource = self
        self.quarterPicker.delegate = self
        self.quarterTextField.inputView = quarterPicker
        
        self.courses = self.realm.objects(Course.self)
        
        if self.editOrAdd == "edit" {
            self.nameTextField.text = self.course!.name
            self.instructorTextField.text = self.course!.instructor
            self.unitTextField.text = "\(self.course!.units)"
            //let row = pickerData[0].index(of: self.course!.quarter)
            //self.quarterPicker.selectRow(row!, inComponent: 0, animated: true)
            self.quarterTextField.text = self.course!.quarter
            self.colorTextField.text = self.course!.courseColor
            recommendedText(self)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        NoteContent.text = course.name
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
            return pickerData.count
        }
        else if pickerView == colorPicker{
            return pickerColor.count
        }
        return 0

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == quarterPicker{
            return pickerData[component].count
        }else if pickerView == colorPicker{
            return pickerColor[component].count
        }
        return 0

    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        if pickerView == quarterPicker{
            return pickerData[component][row]
        }
        else if pickerView == colorPicker{
            return pickerColor[component][row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == quarterPicker{
            //self.quarterTextField.text = pickerData[component][row]
        }else if pickerView == colorPicker{
            self.colorTextField.text = pickerColor[component][row]
        }
        
    }
    
    func quarterDonePressed() {
        self.quarterTextField.resignFirstResponder()
        self.quarterTextField.text = pickerData[0][self.quarterPicker.selectedRow(inComponent: 0)]
    }
    
}
