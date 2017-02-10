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
    
    let realm = try! Realm()
    
    var course: Course?
    var editOrAdd: String = "" // "edit" or "add"
    var courses: Results<Course>!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var quarterPicker: UIPickerView!
    
    
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
            course!.quarter = pickerData[0][quarterPicker.selectedRow(inComponent: 0)]
            Helpers.DB_insert(obj: course!)
        }
        if(editOrAdd=="edit"){
            try! self.realm.write {
                course!.name = nameTextField.text!
                
                course!.instructor = instructorTextField.text!
                course!.units = Int(unitTextField.text!)!
                course!.quarter = pickerData[0][quarterPicker.selectedRow(inComponent: 0)]

            }
        }
        
        
        
        
        let _ = self.navigationController?.popViewController(animated: true)

    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.quarterPicker.dataSource = self
        self.quarterPicker.delegate = self
        
        self.courses = self.realm.objects(Course.self)
        
        if self.editOrAdd == "edit" {
            self.nameTextField.text = self.course!.name
            self.instructorTextField.text = self.course!.instructor
            self.unitTextField.text = "\(self.course!.units)"
            let row = pickerData[0].index(of: self.course!.quarter)
            self.quarterPicker.selectRow(row!, inComponent: 0, animated: true)
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
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        return pickerData[component][row]
    }
    
    
    
    
    
}
